import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:fl_chart/fl_chart.dart';

class TraineeProfileScreen extends ConsumerWidget {
  final Trainee trainee;
  const TraineeProfileScreen({super.key, required this.trainee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary, size: 18),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  trainee.avatarInitials,
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              trainee.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Start Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: FadeSlideEntrance(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHero(trainee: trainee),
                const SizedBox(height: 20),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _StatsCard(trainee: trainee)),
                          const SizedBox(width: 20),
                          Expanded(flex: 7, child: _SessionScoreChart(trainee: trainee)),
                        ],
                      )
                    : Column(
                        children: [
                          _StatsCard(trainee: trainee),
                          const SizedBox(height: 20),
                          _SessionScoreChart(trainee: trainee),
                        ],
                      ),
                const SizedBox(height: 20),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _SkillRadar(trainee: trainee)),
                          const SizedBox(width: 20),
                          Expanded(child: _RemarksCard(trainee: trainee)),
                        ],
                      )
                    : Column(
                        children: [
                          _SkillRadar(trainee: trainee),
                          const SizedBox(height: 20),
                          _RemarksCard(trainee: trainee),
                        ],
                      ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final Trainee trainee;
  const _ProfileHero({required this.trainee});

  Color get _statusColor {
    switch (trainee.status) {
      case TrainingStatus.excelling:
        return AppColors.safe;
      case TrainingStatus.onTrack:
        return AppColors.teal;
      case TrainingStatus.needsAttention:
        return AppColors.warning;
      case TrainingStatus.inactive:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navyBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyCard,
            AppColors.teal.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Row(
        children: [
          // Large squircle avatar
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                trainee.avatarInitials,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainee.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusChip(label: trainee.trade.label, color: AppColors.blue),
                    StatusChip(label: trainee.skillLevel.label, color: AppColors.aiPurple),
                    StatusChip(label: trainee.status.label, color: _statusColor),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text(
                      'Enrolled ${trainee.enrolledDate.day}/${trainee.enrolledDate.month}/${trainee.enrolledDate.year}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score circle
          Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: trainee.accuracyPercent >= 90
                        ? AppColors.safe
                        : trainee.accuracyPercent >= 75
                            ? AppColors.teal
                            : AppColors.warning,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${trainee.accuracyPercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: trainee.accuracyPercent >= 90
                              ? AppColors.safe
                              : AppColors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const Text(
                        'Acc.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Trainee trainee;
  const _StatsCard({required this.trainee});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.teal, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Training Statistics',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          _statRow('Total Sessions', '${trainee.totalSessions}', null),
          _statRow('Detection Accuracy',
              '${trainee.accuracyPercent.toStringAsFixed(1)}%',
              trainee.accuracyPercent >= 85 ? AppColors.safe : AppColors.warning),
          _statRow('Avg Response Time',
              '${trainee.avgResponseTimeSec.toStringAsFixed(1)} sec', null),
          _statRow('Hazards Identified', '${trainee.hazardsIdentified}', AppColors.teal),
          _statRow('Hazards Missed', '${trainee.hazardsMissed}',
              trainee.hazardsMissed > 2 ? AppColors.critical : AppColors.textMuted),
          _statRow('False Alarms', '${trainee.falseAlarms}', null),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Skill Progress',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${(trainee.skillProgress * 100).toInt()}%',
                style: const TextStyle(
                    color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: trainee.skillProgress,
              backgroundColor: AppColors.navyBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionScoreChart extends StatelessWidget {
  final Trainee trainee;
  const _SessionScoreChart({required this.trainee});

  @override
  Widget build(BuildContext context) {
    final scores = trainee.sessionScores;
    final minScore = scores.isEmpty ? 40.0 : scores.reduce((a, b) => a < b ? a : b);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: AppColors.teal, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Session Score Trend',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${scores.length} sessions',
                  style: const TextStyle(color: AppColors.teal, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: (minScore - 10).clamp(0, 100),
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.divider,
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
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        'S${v.toInt() + 1}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: scores
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AppColors.teal,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 3.5,
                        color: AppColors.teal,
                        strokeWidth: 2,
                        strokeColor: AppColors.navyCard,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.teal.withValues(alpha: 0.12),
                          AppColors.teal.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillRadar extends StatelessWidget {
  final Trainee trainee;
  const _SkillRadar({required this.trainee});

  @override
  Widget build(BuildContext context) {
    final acc = trainee.accuracyPercent / 100;
    final resp = 1 - (trainee.avgResponseTimeSec / 40).clamp(0.0, 1.0);
    final loc = (trainee.hazardsIdentified /
            (trainee.hazardsIdentified + trainee.hazardsMissed + 1))
        .clamp(0.0, 1.0);
    final safety =
        1 - (trainee.falseAlarms / (trainee.totalSessions + 1)).clamp(0.0, 1.0);
    final decision =
        (trainee.skillProgress * 0.9 + acc * 0.1).clamp(0.0, 1.0);

    final skills = [
      ('Detection', acc),
      ('Response', resp),
      ('Localization', loc),
      ('Safety', safety),
      ('Decision', decision),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_rounded, color: AppColors.aiPurple, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Skill Radar',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 8),
                radarBorderData: const BorderSide(color: AppColors.navyBorder),
                gridBorderData: const BorderSide(color: AppColors.divider, width: 1),
                titleTextStyle: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                getTitle: (i, _) {
                  const titles = [
                    'Detection', 'Response', 'Localization',
                    'Safety', 'Decision'
                  ];
                  return RadarChartTitle(text: titles[i]);
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.aiPurple.withValues(alpha: 0.18),
                    borderColor: AppColors.aiPurple,
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: [
                      RadarEntry(value: acc * 5),
                      RadarEntry(value: resp * 5),
                      RadarEntry(value: loc * 5),
                      RadarEntry(value: safety * 5),
                      RadarEntry(value: decision * 5),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Skill bars under radar
          ...skills.map((s) => _SkillBar(label: s.$1, value: s.$2)),
        ],
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String label;
  final double value;
  const _SkillBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.navyBorder,
                valueColor: AlwaysStoppedAnimation(
                  value >= 0.8
                      ? AppColors.safe
                      : value >= 0.6
                          ? AppColors.teal
                          : AppColors.warning,
                ),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${(value * 100).toInt()}%',
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemarksCard extends StatelessWidget {
  final Trainee trainee;
  const _RemarksCard({required this.trainee});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.aiPurple.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.aiPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: AppColors.aiPurple, size: 15),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Recommendations',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.aiPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulseDot(color: AppColors.aiPurple, size: 6),
                    SizedBox(width: 5),
                    Text(
                      'AI Generated',
                      style: TextStyle(color: AppColors.aiPurple, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.aiPurple.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.aiPurple.withValues(alpha: 0.15)),
            ),
            child: Text(
              trainee.remarks,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 11, color: AppColors.textMuted),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Practice assessment — not an official certification score',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
