import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/session.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/models/hazard.dart';
import 'package:trainer_app/models/assessment.dart';
import 'package:trainer_app/models/ai_feedback.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final TrainingSession session;
  const SessionDetailScreen({super.key, required this.session});

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final assessment = MockData.assessments[s.id];
    final aiFeedback = MockData.aiFeedbacks[s.id];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mission Audit  •  ${s.id}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.2),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: FadeSlideEntrance(
        child: Column(
          children: [
            _SessionHeader(session: s),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.8), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.teal,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.teal,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: 'Mission Metrics'),
                  Tab(text: 'Flight Timeline'),
                  Tab(text: 'Hazards Encountered'),
                  Tab(text: 'Rubric Assessment'),
                  Tab(text: 'AI Diagnostic Feedback'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _OverviewTab(session: s),
                  _TimelineTab(session: s),
                  _HazardsTab(session: s),
                  _AssessmentTab(session: s, assessment: assessment),
                  _AiFeedbackTab(session: s, feedback: aiFeedback),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  final TrainingSession session;
  const _SessionHeader({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.6), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.35)),
            ),
            alignment: Alignment.center,
            child: Text(
              session.traineeName.split(' ').map((s) => s[0]).take(2).join(),
              style: const TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    session.traineeName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  StatusChip(
                    label: session.status.label.toUpperCase(),
                    color: session.status == SessionStatus.active ? AppColors.safe : AppColors.teal,
                    hasPulse: session.status == SessionStatus.active,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '${session.trade.label}  •  ${session.exercise.label}  •  Assigned Drone: ${session.droneId}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          if (session.score > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session.score} / 100',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'COMPOSITE SCORE',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final TrainingSession session;
  const _OverviewTab({required this.session});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: constraints.maxWidth > 800 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricCard(
                  title: 'Mission Duration',
                  value: session.durationFormatted,
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.teal,
                ),
                MetricCard(
                  title: 'Hazards Detected',
                  value: '${session.hazardsDetected}',
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.warning,
                ),
                MetricCard(
                  title: 'Hazards Missed',
                  value: '${session.hazardsMissed}',
                  icon: Icons.do_not_disturb_on_outlined,
                  iconColor: session.hazardsMissed > 0 ? AppColors.critical : AppColors.safe,
                ),
                MetricCard(
                  title: 'False Positive Flags',
                  value: '${session.falsePositives}',
                  icon: Icons.report_problem_outlined,
                  iconColor: AppColors.high,
                ),
                MetricCard(
                  title: 'Assigned Drone Unit',
                  value: session.droneId,
                  icon: Icons.flight_outlined,
                  iconColor: AppColors.blue,
                ),
                MetricCard(
                  title: 'Exercise Difficulty',
                  value: session.difficulty.label,
                  icon: Icons.tune_outlined,
                  iconColor: AppColors.aiPurple,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final TrainingSession session;
  const _TimelineTab({required this.session});

  @override
  Widget build(BuildContext context) {
    if (session.timeline.isEmpty) {
      return const EmptyState(
        icon: Icons.timeline,
        title: 'No mission timeline recorded',
        subtitle: 'Session timeline events will be captured automatically during flight execution',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(28),
      itemCount: session.timeline.length,
      itemBuilder: (context, i) {
        final event = session.timeline[i];
        final isLast = i == session.timeline.length - 1;
        return _TimelineItem(event: event, isLast: isLast);
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final SessionTimelineEvent event;
  final bool isLast;
  const _TimelineItem({required this.event, required this.isLast});

  Color get _dotColor {
    switch (event.eventType) {
      case 'start':
        return AppColors.teal;
      case 'drone':
        return AppColors.blue;
      case 'sensor':
        return AppColors.warning;
      case 'ai':
        return AppColors.aiPurple;
      case 'trainee':
        return AppColors.safe;
      case 'complete':
        return AppColors.teal;
      default:
        return AppColors.textMuted;
    }
  }

  IconData get _icon {
    switch (event.eventType) {
      case 'start':
        return Icons.play_arrow;
      case 'drone':
        return Icons.flight;
      case 'sensor':
        return Icons.sensors;
      case 'ai':
        return Icons.smart_toy_outlined;
      case 'trainee':
        return Icons.person_outline;
      case 'complete':
        return Icons.check_circle_outline;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}:${event.time.second.toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _dotColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: _dotColor.withValues(alpha: 0.4)),
              ),
              child: Icon(_icon, color: _dotColor, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: AppColors.navyBorder.withValues(alpha: 0.7),
              ),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.navyCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.navyLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (event.detail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.detail!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HazardsTab extends StatelessWidget {
  final TrainingSession session;
  const _HazardsTab({required this.session});

  @override
  Widget build(BuildContext context) {
    if (session.hazards.isEmpty) {
      return const EmptyState(
        icon: Icons.shield_outlined,
        title: 'No hazard events triggered',
        subtitle: 'All telemetry stayed within safe baseline thresholds during this flight',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(28),
      itemCount: session.hazards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final h = session.hazards[i];
        final color = h.riskLevel == RiskLevel.critical
            ? AppColors.critical
            : h.riskLevel == RiskLevel.high
                ? AppColors.high
                : AppColors.warning;

        return AppCard(
          borderColor: color.withValues(alpha: 0.3),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${h.type.label} Spike in Zone ${h.zone}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sensor: ${h.sensorValue} ${h.sensorUnit}  •  AI Confidence: ${h.confidencePercent.toStringAsFixed(0)}%',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusChip(label: h.responseStatus, color: color),
            ],
          ),
        );
      },
    );
  }
}

class _AssessmentTab extends StatelessWidget {
  final TrainingSession session;
  final Assessment? assessment;
  const _AssessmentTab({required this.session, this.assessment});

  @override
  Widget build(BuildContext context) {
    if (assessment == null) {
      return const EmptyState(
        icon: Icons.assignment_turned_in_outlined,
        title: 'Assessment pending evaluation',
        subtitle: 'The rubric score will be calculated once the trainer completes evaluation review',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Competency Rubric Breakdown',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${assessment!.totalScore} / ${assessment!.maxScore} PTS',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...assessment!.categories.map((c) => _CategoryRow(category: c)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final AssessmentCategory category;
  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = category.percentage >= 0.85
        ? AppColors.safe
        : category.percentage >= 0.70
            ? AppColors.teal
            : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                '${category.score} / ${category.maxScore}',
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: category.percentage,
              backgroundColor: AppColors.navyLight,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiFeedbackTab extends StatelessWidget {
  final TrainingSession session;
  final AiFeedback? feedback;
  const _AiFeedbackTab({required this.session, this.feedback});

  @override
  Widget build(BuildContext context) {
    if (feedback == null) {
      return const EmptyState(
        icon: Icons.smart_toy_outlined,
        title: 'AI diagnostic report pending',
        subtitle: 'Complete the mission session to generate automated AI feedback analysis',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            borderColor: AppColors.aiPurple.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.aiPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.smart_toy, color: AppColors.aiPurple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI NEURAL SESSION DIAGNOSTIC',
                          style: TextStyle(
                            color: AppColors.aiPurple,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Automated safety compliance & reaction time audit',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    StatusChip(
                      label: feedback!.overallPerformance.toUpperCase(),
                      color: AppColors.safe,
                    ),
                  ],
                ),
                Divider(height: 28, color: AppColors.navyBorder.withValues(alpha: 0.6)),
                _Section(
                  title: 'Identified Competencies & Strengths',
                  icon: Icons.check_circle_outline,
                  color: AppColors.safe,
                  items: feedback!.strengths,
                ),
                const SizedBox(height: 18),
                _Section(
                  title: 'Recommended Remediation Areas',
                  icon: Icons.trending_up,
                  color: AppColors.warning,
                  items: feedback!.areasForImprovement,
                ),
                const SizedBox(height: 18),
                _Section(
                  title: 'Target Practice Scenarios',
                  icon: Icons.lightbulb_outline,
                  color: AppColors.blue,
                  items: feedback!.recommendations,
                ),
                Divider(height: 28, color: AppColors.navyBorder.withValues(alpha: 0.6)),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.aiPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.aiPurple.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology_outlined, color: AppColors.aiPurple, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Supervising Trainer Advisory',
                            style: TextStyle(
                              color: AppColors.aiPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        feedback!.trainerInsight,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
