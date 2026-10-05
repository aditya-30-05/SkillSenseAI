import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/providers/trainee_provider.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:trainer_app/features/trainees/trainee_profile_screen.dart';

class TraineesScreen extends ConsumerWidget {
  const TraineesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainees = ref.watch(filteredTraineesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeSlideEntrance(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                              color: AppColors.teal,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Trainees',
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
                          'Manage and monitor trainee performance',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  StatusChip(
                    label: '${trainees.length} enrolled',
                    color: AppColors.teal,
                    icon: Icons.school_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search + filter row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.navyCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.navyBorder),
                      ),
                      child: TextField(
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search trainee by name...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (v) =>
                            ref.read(traineeSearchProvider.notifier).state = v,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _TradeFilter(),
                ],
              ),
              const SizedBox(height: 20),

              // Trainees grid
              Expanded(
                child: trainees.isEmpty
                    ? const EmptyState(
                        icon: Icons.school_outlined,
                        title: 'No trainees found',
                        subtitle: 'Try adjusting your search or filters',
                      )
                    : LayoutBuilder(builder: (context, constraints) {
                        final cols = constraints.maxWidth > 900
                            ? 3
                            : constraints.maxWidth > 600
                                ? 2
                                : 1;
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: trainees.length,
                          itemBuilder: (context, i) => _TraineeCard(
                            trainee: trainees[i],
                            onTap: () {
                              ref.read(selectedTraineeProvider.notifier).state =
                                  trainees[i];
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => TraineeProfileScreen(
                                  trainee: trainees[i],
                                ),
                              ));
                            },
                          ),
                        );
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TradeFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(tradeFilterProvider);
    return PopupMenuButton<Trade?>(
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.navyBorder),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.navyCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.navyBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              current?.label ?? 'All Trades',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
      onSelected: (v) => ref.read(tradeFilterProvider.notifier).state = v,
      itemBuilder: (_) => [
        const PopupMenuItem<Trade?>(
          value: null,
          child: Text('All Trades', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ),
        ...Trade.values.map(
          (t) => PopupMenuItem<Trade>(
            value: t,
            child: Text(t.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

class _TraineeCard extends StatefulWidget {
  final Trainee trainee;
  final VoidCallback onTap;

  const _TraineeCard({required this.trainee, required this.onTap});

  @override
  State<_TraineeCard> createState() => _TraineeCardState();
}

class _TraineeCardState extends State<_TraineeCard> {
  bool _hovered = false;

  Color get _statusColor {
    switch (widget.trainee.status) {
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

  Color get _avatarColor {
    final colors = [AppColors.teal, AppColors.blue, AppColors.aiPurple, AppColors.safe];
    return colors[widget.trainee.name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surfaceElevated : AppColors.navyCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? _avatarColor.withValues(alpha: 0.5) : AppColors.navyBorder,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _avatarColor.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + name + status
              Row(
                children: [
                  // Squircle avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _avatarColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _avatarColor.withValues(alpha: 0.25)),
                    ),
                    child: Center(
                      child: Text(
                        widget.trainee.avatarInitials,
                        style: TextStyle(
                          color: _avatarColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trainee.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.trainee.trade.label,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Glowing status dot
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PulseDot(color: _statusColor, size: 7),
                      const SizedBox(width: 5),
                      Text(
                        widget.trainee.status.label,
                        style: TextStyle(color: _statusColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              Container(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),

              // Metrics row
              Row(
                children: [
                  _MetricCell(
                    label: 'Sessions',
                    value: '${widget.trainee.totalSessions}',
                    color: AppColors.textPrimary,
                  ),
                  _MetricCell(
                    label: 'Accuracy',
                    value: '${widget.trainee.accuracyPercent.toStringAsFixed(0)}%',
                    color: widget.trainee.accuracyPercent >= 90
                        ? AppColors.safe
                        : widget.trainee.accuracyPercent >= 75
                            ? AppColors.teal
                            : AppColors.warning,
                  ),
                  _MetricCell(
                    label: 'Avg Resp.',
                    value: '${widget.trainee.avgResponseTimeSec.toStringAsFixed(0)}s',
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Skill progress bar
              Row(
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    '${(widget.trainee.skillProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: widget.trainee.skillProgress >= 0.8
                          ? AppColors.safe
                          : AppColors.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.trainee.skillProgress,
                  backgroundColor: AppColors.navyBorder,
                  valueColor: AlwaysStoppedAnimation(
                    widget.trainee.skillProgress >= 0.8
                        ? AppColors.safe
                        : AppColors.teal,
                  ),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
