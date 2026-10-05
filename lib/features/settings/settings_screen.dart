import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/providers/app_provider.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoMode = ref.watch(demoModeProvider);
    final aiEnabled = ref.watch(aiEnabledProvider);
    final notifications = ref.watch(notificationsProvider);
    final alertThreshold = ref.watch(alertThresholdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeSlideEntrance(
        child: SingleChildScrollView(
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
                              color: AppColors.aiPurple,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Settings',
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
                          'Platform configuration and preferences',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (demoMode)
                    StatusChip(
                      label: 'Demo Mode',
                      color: AppColors.warning,
                      icon: Icons.science_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Account section
              _SettingsSection(
                title: 'Account',
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.teal,
                children: [
                  _InfoRow('Trainer Name', 'Demo Trainer'),
                  _InfoRow('Trainer ID', 'TR-DEMO-001'),
                  _InfoRow('Institution', 'SkillSense Training Center'),
                  _InfoRow('Mode', 'Demo / Prototype'),
                ],
              ),
              const SizedBox(height: 16),

              // Training Settings
              _SettingsSection(
                title: 'Training Settings',
                icon: Icons.tune_rounded,
                iconColor: AppColors.warning,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.notifications_active_rounded,
                                color: AppColors.warning, size: 14),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alert Threshold',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${alertThreshold.toStringAsFixed(1)} ppm — gas concentration trigger',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '${alertThreshold.toStringAsFixed(1)} ppm',
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: AppColors.warning,
                          inactiveTrackColor: AppColors.navyBorder,
                          thumbColor: AppColors.warning,
                          overlayColor: AppColors.warning.withValues(alpha: 0.15),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16),
                        ),
                        child: Slider(
                          value: alertThreshold,
                          min: 1.0,
                          max: 10.0,
                          divisions: 18,
                          label: '${alertThreshold.toStringAsFixed(1)} ppm',
                          onChanged: (v) =>
                              ref.read(alertThresholdProvider.notifier).state = v,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.navyCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 12, color: AppColors.textMuted),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Prototype training threshold — configurable during validation. '
                                'Not an official occupational exposure limit.',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Drone Configuration
              _SettingsSection(
                title: 'Drone Configuration',
                icon: Icons.flight_rounded,
                iconColor: AppColors.blue,
                children: [
                  _InfoRow('Primary Drone', 'DRONE-01 (Alpha-1)'),
                  _InfoRow('Backup Drone', 'DRONE-02 (Beta-2)'),
                  _InfoRow('Connection',
                      'WebSocket — ws://localhost:8000/ws/telemetry'),
                  _InfoRow('MQTT Broker', 'Configurable'),
                ],
              ),
              const SizedBox(height: 16),

              // AI Configuration
              _SettingsSection(
                title: 'AI Configuration',
                icon: Icons.smart_toy_rounded,
                iconColor: AppColors.aiPurple,
                children: [
                  _ToggleRow(
                    label: 'AI Analysis Enabled',
                    subtitle: 'Generate AI feedback after sessions',
                    value: aiEnabled,
                    color: AppColors.aiPurple,
                    onChanged: (v) =>
                        ref.read(aiEnabledProvider.notifier).state = v,
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  _InfoRow('AI Backend', 'Mock (Demo Mode)'),
                  _InfoRow('Production API', 'http://localhost:8000/api/ai/'),
                  _InfoRow(
                      'Note', 'API keys managed by backend — never in Flutter'),
                ],
              ),
              const SizedBox(height: 16),

              // System
              _SettingsSection(
                title: 'System',
                icon: Icons.display_settings_rounded,
                iconColor: AppColors.teal,
                children: [
                  _ToggleRow(
                    label: 'Demo Mode',
                    subtitle: 'Use simulated data without backend',
                    value: demoMode,
                    onChanged: (v) =>
                        ref.read(demoModeProvider.notifier).state = v,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    label: 'Notifications',
                    subtitle: 'Hazard and session alerts',
                    value: notifications,
                    onChanged: (v) =>
                        ref.read(notificationsProvider.notifier).state = v,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // About
              _SettingsSection(
                title: 'About SkillSense AI',
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.textMuted,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.teal.withValues(alpha: 0.05),
                          AppColors.aiPurple.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.navyBorder),
                    ),
                    child: const Text(
                      'AI-enabled diagnostic and practical skill-training platform for skilled trades. '
                      'Designed to enhance hazard detection training through immersive drone-based scenarios.',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Flutter',
                      'FastAPI',
                      'AI/ML',
                      'IoT Sensors',
                      'Drone Telemetry',
                      'WebSocket/MQTT',
                    ]
                        .map((t) => StatusChip(label: t, color: AppColors.teal))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      StatusChip(
                          label: 'SIH PS 26244',
                          color: AppColors.aiPurple),
                      SizedBox(width: 8),
                      StatusChip(
                          label: 'Prototype v1.0',
                          color: AppColors.textMuted),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.teal;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: activeColor,
          inactiveThumbColor: AppColors.textMuted,
          inactiveTrackColor: AppColors.navyBorder,
        ),
      ],
    );
  }
}
