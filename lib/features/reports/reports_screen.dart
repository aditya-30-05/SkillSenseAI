import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/session.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/providers/session_provider.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider)
        .where((s) => s.status == SessionStatus.completed)
        .toList();

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
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Reports',
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
                          'Session reports and trainee performance documents',
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
                    label: '${sessions.length} reports',
                    color: AppColors.blue,
                    icon: Icons.description_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: sessions.isEmpty
                    ? const EmptyState(
                        icon: Icons.description_outlined,
                        title: 'No completed sessions',
                        subtitle:
                            'Reports will appear after sessions are completed',
                      )
                    : ListView.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _ReportCard(session: sessions[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatefulWidget {
  final TrainingSession session;
  const _ReportCard({required this.session});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _hovered = false;

  Color get _scoreColor {
    if (widget.session.score >= 85) return AppColors.safe;
    if (widget.session.score >= 70) return AppColors.teal;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final assessment = MockData.assessments[widget.session.id];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.surfaceElevated : AppColors.navyCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? AppColors.blue.withValues(alpha: 0.4)
                : AppColors.navyBorder,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // File icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.insert_drive_file_rounded,
                      color: AppColors.teal, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.id,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.session.traineeName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.session.trade.label} · ${widget.session.exercise.label}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _scoreColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: _scoreColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${widget.session.score}/100',
                        style: TextStyle(
                          color: _scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Score',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 14),
            // Stats chips
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoPill(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: widget.session.durationFormatted),
                _InfoPill(
                    icon: Icons.warning_amber_rounded,
                    label: 'Hazards',
                    value: '${widget.session.hazardsDetected} detected'),
                _InfoPill(
                    icon: Icons.flight_rounded,
                    label: 'Drone',
                    value: widget.session.droneId),
                _InfoPill(
                    icon: Icons.equalizer_rounded,
                    label: 'Difficulty',
                    value: widget.session.difficulty.label),
                if (assessment != null)
                  _InfoPill(
                    icon: Icons.gps_fixed_rounded,
                    label: 'Accuracy',
                    value:
                        '${(assessment.totalScore / assessment.maxScore * 100).toStringAsFixed(0)}%',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'View Report',
                    icon: Icons.visibility_outlined,
                    color: AppColors.teal,
                    onTap: () => _showReport(context, widget.session),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Export PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    color: AppColors.textSecondary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'PDF export would be generated here (production feature)'),
                          backgroundColor: AppColors.navyCard,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReport(BuildContext context, TrainingSession session) {
    showDialog(
      context: context,
      builder: (_) => _ReportDialog(session: session),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoPill(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

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
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.6)
                  : AppColors.navyBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 15, color: widget.color),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportDialog extends StatelessWidget {
  final TrainingSession session;
  const _ReportDialog({required this.session});

  @override
  Widget build(BuildContext context) {
    final assessment = MockData.assessments[session.id];
    final aiFeedback = MockData.aiFeedbacks[session.id];

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.teal.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: const Border(
                    bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_rounded,
                        color: AppColors.teal, size: 18),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SkillSense AI',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Training Session Report',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${session.score}/100',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _reportRow('Session ID', session.id),
                    _reportRow('Trainee', session.traineeName),
                    _reportRow('Trade', session.trade.label),
                    _reportRow('Exercise', session.exercise.label),
                    _reportRow('Drone', session.droneId),
                    _reportRow('Duration', session.durationFormatted),
                    _reportRow(
                        'Hazards Detected', '${session.hazardsDetected}'),
                    _reportRow(
                        'False Positives', '${session.falsePositives}'),
                    if (assessment != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Assessment Breakdown',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...assessment.categories.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(c.name,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ),
                                Text(
                                  '${c.score}/${c.maxScore}',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: c.score / c.maxScore,
                                      backgroundColor: AppColors.navyBorder,
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              AppColors.teal),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                    if (aiFeedback != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.aiPurple.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppColors.aiPurple.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.smart_toy_rounded,
                                    color: AppColors.aiPurple, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'AI Trainer Insight',
                                  style: TextStyle(
                                    color: AppColors.aiPurple,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              aiFeedback.trainerInsight,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.navyCard,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.navyBorder),
                      ),
                      child: const Text(
                        'Practice Assessment — not an official NSQF certification. '
                        'AI-assisted analysis. Prototype v1.0 · SIH PS 26244',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_rounded, size: 15),
                      label: const Text('Share Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
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

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
