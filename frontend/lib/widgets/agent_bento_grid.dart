import 'package:flutter/material.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/session.dart';
import 'package:trainer_app/services/simulation_service.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

/// Bento Grid Layout widget that visually reorganizes the existing
/// dashboard telemetry and session KPI metrics into an asymmetric,
/// modern aerospace bento layout.
class AgentBentoGrid extends StatelessWidget {
  final List<TrainingSession> sessions;
  final SimulationData simData;
  final VoidCallback? onLiveCockpitTap;

  const AgentBentoGrid({
    super.key,
    required this.sessions,
    required this.simData,
    this.onLiveCockpitTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeSessions =
        sessions.where((s) => s.status == SessionStatus.active).length;
    final completedSessions =
        sessions.where((s) => s.status == SessionStatus.completed).toList();
    final avgScore = completedSessions.isEmpty
        ? 0.0
        : completedSessions.map((s) => s.score).reduce((a, b) => a + b) /
            completedSessions.length;
    final totalHazards = MockData.hazardHistory.length;
    final isFlightActive = simData.state == SimulationState.running ||
        simData.state == SimulationState.hazardPhase;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final isMedium = constraints.maxWidth >= 640 && !isWide;

        if (isWide) {
          return Column(
            children: [
              // Row 1: Primary Drone Unit (Span 2) + Cohort Score (Span 1)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _BentoCard(
                      borderColor: AppColors.teal.withValues(alpha: 0.35),
                      onTap: onLiveCockpitTap,
                      child: _DroneTelemetryBento(
                        simData: simData,
                        isFlightActive: isFlightActive,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 4,
                    child: _BentoCard(
                      child: _CohortScoreBento(avgScore: avgScore),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Row 2: Active Sessions (Span 1) + Hazard Metrics (Span 1) + AI Status (Span 1)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _BentoCard(
                      child: _ActiveSessionsBento(activeCount: activeSessions),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 4,
                    child: _BentoCard(
                      child: _HazardsDetectedBento(totalHazards: totalHazards),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 3,
                    child: _BentoCard(
                      child: _AiDiagnosticBento(isFlightActive: isFlightActive),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (isMedium) {
          return Column(
            children: [
              _BentoCard(
                borderColor: AppColors.teal.withValues(alpha: 0.35),
                onTap: onLiveCockpitTap,
                child: _DroneTelemetryBento(
                  simData: simData,
                  isFlightActive: isFlightActive,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _BentoCard(
                      child: _CohortScoreBento(avgScore: avgScore),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BentoCard(
                      child: _ActiveSessionsBento(activeCount: activeSessions),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _BentoCard(
                      child: _HazardsDetectedBento(totalHazards: totalHazards),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BentoCard(
                      child: _AiDiagnosticBento(isFlightActive: isFlightActive),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Mobile single column stack
          return Column(
            children: [
              _BentoCard(
                borderColor: AppColors.teal.withValues(alpha: 0.35),
                onTap: onLiveCockpitTap,
                child: _DroneTelemetryBento(
                  simData: simData,
                  isFlightActive: isFlightActive,
                ),
              ),
              const SizedBox(height: 14),
              _BentoCard(child: _CohortScoreBento(avgScore: avgScore)),
              const SizedBox(height: 14),
              _BentoCard(child: _ActiveSessionsBento(activeCount: activeSessions)),
              const SizedBox(height: 14),
              _BentoCard(child: _HazardsDetectedBento(totalHazards: totalHazards)),
              const SizedBox(height: 14),
              _BentoCard(child: _AiDiagnosticBento(isFlightActive: isFlightActive)),
            ],
          );
        }
      },
    );
  }
}

class _BentoCard extends StatefulWidget {
  final Widget child;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _BentoCard({
    required this.child,
    this.borderColor,
    this.onTap,
  });

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -2.5 : 0, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF121926) : AppColors.navyCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? (widget.borderColor ?? AppColors.teal.withValues(alpha: 0.45))
                  : (widget.borderColor ?? AppColors.navyBorder),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Bento Tile 1: Drone Telemetry & Mission Connection ──────────────────────
class _DroneTelemetryBento extends StatelessWidget {
  final SimulationData simData;
  final bool isFlightActive;

  const _DroneTelemetryBento({
    required this.simData,
    required this.isFlightActive,
  });

  @override
  Widget build(BuildContext context) {
    final battery = simData.telemetry.batteryPercent;
    final altitude = simData.telemetry.altitudeM.toStringAsFixed(1);
    final signal = simData.telemetry.signalStrength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flight, color: AppColors.teal, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRIMARY DRONE: DRONE-01',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Alpha-1 Quadcopter • Sub-GHz Link 98%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isFlightActive ? AppColors.safe : AppColors.teal).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isFlightActive ? AppColors.safe : AppColors.teal).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulseDot(
                    color: isFlightActive ? AppColors.safe : AppColors.teal,
                    size: 6,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFlightActive ? 'MISSION IN FLIGHT' : 'STANDBY BASE',
                    style: TextStyle(
                      color: isFlightActive ? AppColors.safe : AppColors.teal,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MetricBadge(
                label: 'BATTERY',
                value: '$battery%',
                color: battery > 30 ? AppColors.teal : AppColors.critical,
                icon: Icons.battery_charging_full,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricBadge(
                label: 'ALTITUDE',
                value: '${altitude}m',
                color: AppColors.blue,
                icon: Icons.height,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricBadge(
                label: 'SIGNAL LINK',
                value: '$signal%',
                color: AppColors.aiPurple,
                icon: Icons.wifi,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navyLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.navyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bento Tile 2: Cohort Average Score ──────────────────────────────────────
class _CohortScoreBento extends StatelessWidget {
  final double avgScore;

  const _CohortScoreBento({required this.avgScore});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_outlined, color: AppColors.teal, size: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.safe.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '+4.2% cohort gain',
                style: TextStyle(
                  color: AppColors.safe,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '${avgScore.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cohort Average Score',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Bento Tile 3: Active Trainee Sessions ───────────────────────────────────
class _ActiveSessionsBento extends StatelessWidget {
  final int activeCount;

  const _ActiveSessionsBento({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people_outline, color: AppColors.blue, size: 18),
            ),
            const StatusChip(
              label: 'LIVE',
              color: AppColors.blue,
              hasPulse: true,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '$activeCount',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Active Flight Sessions',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Bento Tile 4: Hazards Detected ──────────────────────────────────────────
class _HazardsDetectedBento extends StatelessWidget {
  final int totalHazards;

  const _HazardsDetectedBento({required this.totalHazards});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
            ),
            const Text(
              '91.2% detected',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '$totalHazards',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Total Hazards Logged',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Bento Tile 5: AI Diagnostic Engine ──────────────────────────────────────
class _AiDiagnosticBento extends StatelessWidget {
  final bool isFlightActive;

  const _AiDiagnosticBento({required this.isFlightActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.aiPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology_outlined, color: AppColors.aiPurple, size: 18),
            ),
            const Text(
              'Online',
              style: TextStyle(
                color: AppColors.aiPurple,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'AI Copilot',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Diagnostic scoring ready',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
