import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/session.dart';
import 'package:trainer_app/models/trainee.dart';
import 'package:trainer_app/providers/session_provider.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:trainer_app/features/sessions/session_detail_screen.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  SessionStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final allSessions = ref.watch(sessionListProvider);
    final sessions = _statusFilter == null
        ? allSessions
        : allSessions.where((s) => s.status == _statusFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeSlideEntrance(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Training Sessions Registry',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Schedule new diagnostic missions and review completed assessment records',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showNewSession(context, ref),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('New Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: const Color(0xFF080A0F),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Filter row
              Row(
                children: [
                  _filterTab('All Sessions (${allSessions.length})', null),
                  const SizedBox(width: 8),
                  _filterTab('Active', SessionStatus.active),
                  const SizedBox(width: 8),
                  _filterTab('Completed', SessionStatus.completed),
                  const SizedBox(width: 8),
                  _filterTab('Paused', SessionStatus.paused),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: sessions.isEmpty
                    ? const EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No sessions found',
                        subtitle: 'No training missions match the current status filter.',
                      )
                    : ListView.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          return _SessionCard(
                            session: sessions[i],
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => SessionDetailScreen(session: sessions[i]),
                              ));
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterTab(String label, SessionStatus? status) {
    final isSelected = _statusFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal.withValues(alpha: 0.12) : AppColors.navyLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.navyBorder.withValues(alpha: 0.7),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.teal : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showNewSession(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => const _NewSessionDialog(),
    );
  }
}

class _NewSessionDialog extends ConsumerStatefulWidget {
  const _NewSessionDialog();

  @override
  ConsumerState<_NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends ConsumerState<_NewSessionDialog> {
  String? _traineeId;
  String? _traineeName;
  String? _droneId;
  ExerciseType? _exercise;
  SkillLevel _difficulty = SkillLevel.intermediate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navyBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment_add, color: AppColors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Launch Training Mission',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a trainee, designate a drone unit, and set target exercise parameters',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _DropdownField<String>(
              label: 'Assign Trainee',
              value: _traineeId,
              items: MockData.trainees.map((t) => (t.id, '${t.name} (${t.trade.label})')).toList(),
              onChanged: (id) {
                final t = MockData.trainees.firstWhere((e) => e.id == id);
                setState(() {
                  _traineeId = id;
                  _traineeName = t.name;
                });
              },
            ),
            const SizedBox(height: 16),
            _DropdownField<String>(
              label: 'Assigned Drone Unit',
              value: _droneId,
              items: const [
                ('DRONE-01', 'DRONE-01 • Alpha-1 Quadcopter (Ready)'),
                ('DRONE-02', 'DRONE-02 • Beta-2 Inspection Drone (Standby)'),
                ('DRONE-03', 'DRONE-03 • Gamma-3 Hazard Unit (Standby)'),
              ],
              onChanged: (v) => setState(() => _droneId = v),
            ),
            const SizedBox(height: 16),
            _DropdownField<ExerciseType>(
              label: 'Exercise Scenario',
              value: _exercise,
              items: ExerciseType.values.map((e) => (e, e.label)).toList(),
              onChanged: (v) => setState(() => _exercise = v),
            ),
            const SizedBox(height: 18),
            const Text(
              'SIMULATION DIFFICULTY',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Row(
              children: SkillLevel.values.map((lvl) {
                final selected = _difficulty == lvl;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = lvl),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.teal.withValues(alpha: 0.15) : AppColors.navyLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? AppColors.teal : AppColors.navyBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          lvl.name.toUpperCase(),
                          style: TextStyle(
                            color: selected ? AppColors.teal : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: const Color(0xFF080A0F),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                  child: const Text('Start Session', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit => _traineeId != null && _droneId != null && _exercise != null;

  void _submit() {
    final session = TrainingSession(
      id: 'S${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      traineeId: _traineeId!,
      traineeName: _traineeName ?? 'Unknown',
      trade: MockData.trainees.firstWhere((t) => t.id == _traineeId).trade,
      exercise: _exercise!,
      difficulty: _difficulty,
      droneId: _droneId!,
      status: SessionStatus.active,
      startTime: DateTime.now(),
      hazards: [],
      hazardsDetected: 0,
      hazardsMissed: 0,
      falsePositives: 0,
      score: 0,
      durationSec: 0,
      timeline: [],
    );
    ref.read(sessionListProvider.notifier).addSession(session);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session started for $_traineeName'),
        backgroundColor: AppColors.safe,
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          dropdownColor: AppColors.surfaceElevated,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          hint: Text(
            'Select $label',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item.$1,
                    child: Text(item.$2),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ── Session Card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final TrainingSession session;
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.onTap});

  Color get _statusColor {
    switch (session.status) {
      case SessionStatus.active:
        return AppColors.safe;
      case SessionStatus.completed:
        return AppColors.teal;
      case SessionStatus.paused:
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.assignment_outlined, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      session.id,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: session.status.label,
                      color: _statusColor,
                      hasPulse: session.status == SessionStatus.active,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session.traineeName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.trade.label}  •  ${session.exercise.label} (${session.droneId})',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (session.score > 0)
                Text(
                  '${session.score} pts',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                session.durationFormatted,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              Text(
                '${session.hazardsDetected} detected / ${session.hazardsMissed} missed',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
        ],
      ),
    );
  }
}
