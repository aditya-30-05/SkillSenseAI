import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/hazard.dart';
import 'package:trainer_app/models/session.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/providers/app_provider.dart';
import 'package:trainer_app/providers/session_provider.dart';
import 'package:trainer_app/services/simulation_service.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    final simData = ref.watch(simulationProvider);
    final isWide = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeSlideEntrance(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 20),
              _SystemStatus(simData: simData),
              const SizedBox(height: 24),
              // KPI Cards
              _KpiCards(sessions: sessions),
              const SizedBox(height: 24),
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _LiveActivity(sessions: sessions)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _RecentAlerts()),
                      ],
                    )
                  : Column(
                      children: [
                        _LiveActivity(sessions: sessions),
                        const SizedBox(height: 20),
                        _RecentAlerts(),
                      ],
                    ),
              const SizedBox(height: 24),
              _PerformanceTrend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$greeting, Trainer',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'STATION 01',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Facility monitoring, real-time drone telemetry, and cohort safety assessments',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(navIndexProvider.notifier).state = 2; // Navigate to Live Monitor
          },
          icon: const Icon(Icons.videocam_outlined, size: 17),
          label: const Text('Live Cockpit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: const Color(0xFF080A0F),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

class _SystemStatus extends StatelessWidget {
  final SimulationData simData;
  const _SystemStatus({required this.simData});

  @override
  Widget build(BuildContext context) {
    final isRunning = simData.state == SimulationState.running ||
        simData.state == SimulationState.hazardPhase;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _StatusPill(
          label: 'Telemetry Online',
          color: AppColors.safe,
          hasPulse: true,
        ),
        _StatusPill(
          label: isRunning ? 'Drone Active in Flight' : 'Drone Standby (Base)',
          color: isRunning ? AppColors.teal : AppColors.textSecondary,
          hasPulse: isRunning,
        ),
        _StatusPill(
          label: isRunning ? 'Sensors Streaming 1Hz' : 'Sensors Armed',
          color: isRunning ? AppColors.blue : AppColors.textSecondary,
        ),
        _StatusPill(
          label: 'AI Diagnostic Engine Ready',
          color: AppColors.aiPurple,
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool hasPulse;

  const _StatusPill({
    required this.label,
    required this.color,
    this.hasPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPulse)
            PulseDot(color: color, size: 6)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCards extends StatelessWidget {
  final List<TrainingSession> sessions;
  const _KpiCards({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final active = sessions.where((s) => s.status == SessionStatus.active).length;
    final completed = sessions.where((s) => s.status == SessionStatus.completed);
    final avgScore = completed.isEmpty
        ? 0.0
        : completed.map((s) => s.score).reduce((a, b) => a + b) / completed.length;
    final totalHazards = MockData.hazardHistory.length;

    return LayoutBuilder(builder: (context, constraints) {
      final crossCount = constraints.maxWidth > 900
          ? 3
          : constraints.maxWidth > 580
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: crossCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.65,
        children: [
          MetricCard(
            title: 'Enrolled Trainees',
            value: '${MockData.trainees.length}',
            subtitle: '3 Active Now',
            icon: Icons.school_outlined,
            iconColor: AppColors.teal,
          ),
          MetricCard(
            title: 'Active Sessions',
            value: '$active',
            subtitle: 'Live In Flight',
            icon: Icons.flight_takeoff_outlined,
            iconColor: AppColors.safe,
          ),
          MetricCard(
            title: 'Hazards Detected Today',
            value: '$totalHazards',
            subtitle: '100% Verified',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
          ),
          MetricCard(
            title: 'Avg Detection Accuracy',
            value: '91.6%',
            subtitle: '+2.4% this week',
            icon: Icons.track_changes_outlined,
            iconColor: AppColors.blue,
          ),
          MetricCard(
            title: 'Average Response Time',
            value: '18.4s',
            subtitle: '-3.2s faster',
            icon: Icons.timer_outlined,
            iconColor: AppColors.teal,
          ),
          MetricCard(
            title: 'Cohort Completion',
            value: '84%',
            subtitle: '${completed.length}/${sessions.length} Complete • ${avgScore.toStringAsFixed(0)} pts',
            icon: Icons.verified_outlined,
            iconColor: AppColors.aiPurple,
          ),
        ],
      );
    });
  }
}

class _LiveActivity extends StatelessWidget {
  final List<TrainingSession> sessions;
  const _LiveActivity({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final active = sessions
        .where((s) => s.status == SessionStatus.active || s.status == SessionStatus.completed)
        .take(5)
        .toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Live Training Activity',
            subtitle: 'Recent and ongoing trainee exercise sessions',
          ),
          const SizedBox(height: 18),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.2),
              1: FlexColumnWidth(1.6),
              2: FlexColumnWidth(1.1),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.8), width: 1),
                  ),
                ),
                children: [
                  _tableHeader('TRAINEE'),
                  _tableHeader('TRADE'),
                  _tableHeader('DRONE'),
                  _tableHeader('STATUS'),
                  _tableHeader('SCORE'),
                ],
              ),
              ...active.map((s) => TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.navyBorder.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                s.traineeName.split(' ').map((n) => n[0]).take(2).join(),
                                style: const TextStyle(
                                  color: AppColors.teal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.traineeName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          s.trade.label,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.navyLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s.droneId,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: StatusChip(
                          label: s.status.label,
                          color: s.status == SessionStatus.active ? AppColors.safe : AppColors.teal,
                          hasPulse: s.status == SessionStatus.active,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          s.score > 0 ? '${s.score} pts' : '—',
                          style: TextStyle(
                            color: s.score > 0 ? AppColors.textPrimary : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: s.score > 0 ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      );
}

class _RecentAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = MockData.hazardHistory.take(4).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Critical Safety Alerts',
            subtitle: 'Real-time hazard detections & threshold breaches',
          ),
          const SizedBox(height: 16),
          ...alerts.map((h) => _AlertItem(hazard: h)),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final HazardEvent hazard;
  const _AlertItem({required this.hazard});

  Color get _color {
    switch (hazard.riskLevel) {
      case RiskLevel.critical:
        return AppColors.critical;
      case RiskLevel.high:
        return AppColors.high;
      case RiskLevel.warning:
        return AppColors.warning;
      default:
        return AppColors.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ago = DateTime.now().difference(hazard.detectedAt);
    final agoStr = ago.inMinutes < 60 ? '${ago.inMinutes}m ago' : '${ago.inHours}h ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: _color, size: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${hazard.type.label} — ${hazard.riskLevel.label.toUpperCase()}',
                  style: TextStyle(
                    color: _color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Text(
                agoStr,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'Zone ${hazard.zone}  •  ${hazard.sensorValue} ${hazard.sensorUnit}  •  Confidence ${hazard.confidencePercent.toStringAsFixed(0)}%',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTrend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accuracyPoints = [72.0, 75, 78, 80, 83, 85, 87, 88, 90, 93];
    final responsePoints = [34.0, 31, 28, 26, 24, 22, 21, 20, 19, 18];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Cohort Performance Trajectory',
                  subtitle: 'Historical accuracy (%) and reaction latency (sec) across the last 10 sessions',
                ),
              ),
              _legend(AppColors.teal, 'Accuracy (%)'),
              const SizedBox(width: 16),
              _legend(AppColors.warning, 'Response Latency (sec)', dashed: true),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.navyBorder.withValues(alpha: 0.6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        'Session ${v.toInt() + 1}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: accuracyPoints
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.teal,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.teal.withValues(alpha: 0.18),
                          AppColors.teal.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: responsePoints
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.warning,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 4],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label, {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
