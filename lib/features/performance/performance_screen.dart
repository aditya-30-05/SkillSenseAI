import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeSlideEntrance(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _PerformanceHeader(),
              SizedBox(height: 24),
              _TopMetrics(),
              SizedBox(height: 24),
              _AccuracyTrendChart(),
              SizedBox(height: 24),
              _TraineeLeaderboard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceHeader extends StatelessWidget {
  const _PerformanceHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Performance Analytics',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Text(
                'Cohort-wide training performance and skill metrics',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
        const Spacer(),
        StatusChip(
          label: 'Cycle Active',
          color: AppColors.safe,
          icon: Icons.circle,
        ),
      ],
    );
  }
}

class _TopMetrics extends StatelessWidget {
  const _TopMetrics();

  @override
  Widget build(BuildContext context) {
    final trainees = MockData.trainees;
    final avgAcc =
        trainees.map((t) => t.accuracyPercent).reduce((a, b) => a + b) /
            trainees.length;
    final avgResp = trainees
            .map((t) => t.avgResponseTimeSec)
            .reduce((a, b) => a + b) /
        trainees.length;
    final topPerformer = trainees.reduce(
        (a, b) => a.accuracyPercent > b.accuracyPercent ? a : b);
    final excelling =
        trainees.where((t) => t.status == TrainingStatus.excelling).length;

    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 800 ? 4 : 2;
      return GridView.count(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MetricCard(
            title: 'Avg Detection Accuracy',
            value: '${avgAcc.toStringAsFixed(1)}%',
            subtitle: '+3.2% vs last cycle',
            icon: Icons.gps_fixed_rounded,
            iconColor: AppColors.teal,
          ),
          MetricCard(
            title: 'Avg Response Time',
            value: '${avgResp.toStringAsFixed(1)}s',
            subtitle: '-1.4s improvement',
            icon: Icons.timer_rounded,
            iconColor: AppColors.blue,
          ),
          MetricCard(
            title: 'Top Performer',
            value: topPerformer.name.split(' ')[0],
            subtitle: '${topPerformer.accuracyPercent.toStringAsFixed(0)}% accuracy',
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.warning,
          ),
          MetricCard(
            title: 'Excelling',
            value: '$excelling/${trainees.length}',
            subtitle: '${(excelling / trainees.length * 100).toStringAsFixed(0)}% of cohort',
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.safe,
          ),
        ],
      );
    });
  }
}

class _AccuracyTrendChart extends StatelessWidget {
  const _AccuracyTrendChart();

  @override
  Widget build(BuildContext context) {
    final data = [72.0, 75, 78, 80, 83, 85, 87, 88, 90, 92];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppColors.teal, size: 16),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cohort Accuracy Trend',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Average detection accuracy over last 10 cycles',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.safe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: AppColors.safe, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '+27.8% total growth',
                      style: TextStyle(color: AppColors.safe, fontSize: 11),
                    ),
                  ],
                ),
              ),
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
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}%',
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
                        'C${v.toInt() + 1}',
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
                minY: 60,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) =>
                            FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: AppColors.teal,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
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
                          AppColors.teal.withValues(alpha: 0.15),
                          AppColors.teal.withValues(alpha: 0.01),
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

class _TraineeLeaderboard extends StatelessWidget {
  const _TraineeLeaderboard();

  @override
  Widget build(BuildContext context) {
    final sorted = [...MockData.trainees]
      ..sort((a, b) => b.accuracyPercent.compareTo(a.accuracyPercent));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.leaderboard_rounded,
                    color: AppColors.warning, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Trainee Leaderboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '${sorted.length} trainees',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          ...sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final t = entry.value;
            return _LeaderboardRow(rank: i + 1, trainee: t);
          }),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatefulWidget {
  final int rank;
  final Trainee trainee;
  const _LeaderboardRow({required this.rank, required this.trainee});

  @override
  State<_LeaderboardRow> createState() => _LeaderboardRowState();
}

class _LeaderboardRowState extends State<_LeaderboardRow> {
  bool _hovered = false;

  Color get _medalColor {
    if (widget.rank == 1) return const Color(0xFFFFD700);
    if (widget.rank == 2) return const Color(0xFFC0C0C0);
    if (widget.rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textMuted;
  }

  IconData get _medalIcon {
    if (widget.rank == 1) return Icons.emoji_events_rounded;
    if (widget.rank == 2) return Icons.emoji_events_rounded;
    if (widget.rank == 3) return Icons.emoji_events_rounded;
    return Icons.person_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: _hovered
              ? Border.all(color: AppColors.navyBorder)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Rank indicator
            SizedBox(
              width: 36,
              child: widget.rank <= 3
                  ? Icon(_medalIcon, color: _medalColor, size: 22)
                  : Text(
                      '#${widget.rank}',
                      style: TextStyle(
                        color: _medalColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
            ),
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
                border: widget.rank <= 3
                    ? Border.all(color: _medalColor.withValues(alpha: 0.4))
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.trainee.avatarInitials,
                  style: const TextStyle(color: AppColors.teal, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + trade
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trainee.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: widget.rank <= 3 ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.trainee.trade.label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Accuracy + progress
            SizedBox(
              width: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.trainee.accuracyPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: widget.rank == 1
                          ? _medalColor
                          : AppColors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.trainee.accuracyPercent / 100,
                      backgroundColor: AppColors.navyBorder,
                      valueColor: AlwaysStoppedAnimation(
                        widget.rank == 1 ? _medalColor : AppColors.teal,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
