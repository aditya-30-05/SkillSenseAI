import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/hazard.dart';
import 'package:trainer_app/services/simulation_service.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

class HazardMapScreen extends ConsumerStatefulWidget {
  const HazardMapScreen({super.key});

  @override
  ConsumerState<HazardMapScreen> createState() => _HazardMapScreenState();
}

class _HazardMapScreenState extends ConsumerState<HazardMapScreen> {
  HazardType? _filter;
  HazardEvent? _selected;

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationProvider);
    final allHazards = [
      ...MockData.hazardHistory,
      if (sim.activeHazard != null) sim.activeHazard!,
    ];
    final filtered = _filter == null
        ? allHazards
        : allHazards.where((h) => h.type == _filter).toList();

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
                        'Hazard Geospatial Radar',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Facility blueprint zones, anomaly pinpoints, and sensor severity breakdown',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Filter Pills
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('All Hazards', null),
                      _filterChip('Gas Leaks', HazardType.gas),
                      _filterChip('Water / Pressure', HazardType.water),
                      _filterChip('Thermal Spikes', HazardType.heat),
                      _filterChip('Electrical / UV', HazardType.uv),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 960;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _MapCanvas(
                                hazards: filtered,
                                simData: sim,
                                onSelect: (h) => setState(() => _selected = h),
                                selected: _selected,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 320,
                              child: Column(
                                children: [
                                  if (_selected != null) ...[
                                    _HazardDetail(hazard: _selected!),
                                    const SizedBox(height: 16),
                                  ],
                                  Expanded(
                                    child: _HazardList(
                                      hazards: filtered,
                                      selected: _selected,
                                      onSelect: (h) => setState(() => _selected = h),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: 320,
                              child: _MapCanvas(
                                hazards: filtered,
                                simData: sim,
                                onSelect: (h) => setState(() => _selected = h),
                                selected: _selected,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_selected != null) ...[
                              _HazardDetail(hazard: _selected!),
                              const SizedBox(height: 16),
                            ],
                            Expanded(
                              child: _HazardList(
                                hazards: filtered,
                                selected: _selected,
                                onSelect: (h) => setState(() => _selected = h),
                              ),
                            ),
                          ],
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, HazardType? type) {
    final selected = _filter == type;
    return GestureDetector(
      onTap: () => setState(() => _filter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal.withValues(alpha: 0.14) : AppColors.navyLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.navyBorder.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.teal : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  final List<HazardEvent> hazards;
  final SimulationData simData;
  final ValueChanged<HazardEvent> onSelect;
  final HazardEvent? selected;

  const _MapCanvas({
    required this.hazards,
    required this.simData,
    required this.onSelect,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070A0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CustomPaint(
          painter: _HazardMapPainter(
            hazards: hazards,
            simData: simData,
            selected: selected,
          ),
          child: GestureDetector(
            onTapUp: (details) {
              if (hazards.isNotEmpty) {
                onSelect(hazards[0]);
              }
            },
            child: Stack(
              children: [
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SEVERITY SCALE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _legendItem(AppColors.safe, 'Safe'),
                            const SizedBox(width: 10),
                            _legendItem(AppColors.warning, 'Warning'),
                            const SizedBox(width: 10),
                            _legendItem(AppColors.high, 'Elevated'),
                            const SizedBox(width: 10),
                            _legendItem(AppColors.critical, 'Critical'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PulseDot(color: AppColors.teal, size: 6),
                        const SizedBox(width: 6),
                        Text(
                          'RADAR ACTIVE • ${hazards.length} PINS',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _HazardMapPainter extends CustomPainter {
  final List<HazardEvent> hazards;
  final SimulationData simData;
  final HazardEvent? selected;

  _HazardMapPainter({
    required this.hazards,
    required this.simData,
    this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF131923)
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      canvas.drawLine(
        Offset(size.width * i / 8, 0),
        Offset(size.width * i / 8, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 8),
        Offset(size.width, size.height * i / 8),
        gridPaint,
      );
    }

    // Zone outlines
    final zones = [
      {'label': 'ZONE A  •  CHEMICAL STORAGE', 'x': 0.05, 'y': 0.05, 'w': 0.28, 'h': 0.42},
      {'label': 'ZONE B  •  PIPE GALLERY', 'x': 0.36, 'y': 0.05, 'w': 0.28, 'h': 0.42},
      {'label': 'ZONE C  •  WELDING FACILITY', 'x': 0.67, 'y': 0.05, 'w': 0.28, 'h': 0.42},
      {'label': 'BASE DOCK  •  GROUND STN', 'x': 0.05, 'y': 0.54, 'w': 0.28, 'h': 0.40},
      {'label': 'ZONE D  •  ELECTRICAL ROOM', 'x': 0.67, 'y': 0.54, 'w': 0.28, 'h': 0.40},
    ];

    final zoneStroke = Paint()
      ..color = const Color(0xFF1E2738)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final z in zones) {
      final rect = Rect.fromLTWH(
        size.width * (z['x'] as double),
        size.height * (z['y'] as double),
        size.width * (z['w'] as double),
        size.height * (z['h'] as double),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), zoneStroke);
      final span = TextSpan(
        text: z['label'] as String,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      );
      final painter = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      painter.paint(
        canvas,
        Offset(
          size.width * (z['x'] as double) + 10,
          size.height * (z['y'] as double) + 10,
        ),
      );
    }

    // Drone position marker
    final dronePos = Offset(size.width * 0.16, size.height * 0.72);
    canvas.drawCircle(dronePos, 16, Paint()..color = AppColors.teal.withValues(alpha: 0.15));
    canvas.drawCircle(dronePos, 9, Paint()..color = AppColors.teal);

    // Hazard markers
    final positions = [
      Offset(size.width * 0.19, size.height * 0.26),
      Offset(size.width * 0.50, size.height * 0.24),
      Offset(size.width * 0.81, size.height * 0.26),
      Offset(size.width * 0.48, size.height * 0.72),
      Offset(size.width * 0.81, size.height * 0.72),
    ];

    for (int i = 0; i < hazards.length && i < positions.length; i++) {
      final h = hazards[i];
      final pos = positions[i];
      final color = _colorFor(h.riskLevel);
      final isSelected = selected?.id == h.id;

      canvas.drawCircle(pos, isSelected ? 24 : 18, Paint()..color = color.withValues(alpha: 0.18));
      canvas.drawCircle(pos, isSelected ? 15 : 12, Paint()..color = color.withValues(alpha: 0.4));
      canvas.drawCircle(pos, 7, Paint()..color = color);

      if (isSelected) {
        canvas.drawCircle(
          pos,
          24,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  Color _colorFor(RiskLevel r) {
    switch (r) {
      case RiskLevel.critical:
        return AppColors.critical;
      case RiskLevel.high:
        return AppColors.high;
      case RiskLevel.warning:
        return AppColors.warning;
      case RiskLevel.safe:
        return AppColors.safe;
    }
  }

  @override
  bool shouldRepaint(_HazardMapPainter old) => true;
}

class _HazardDetail extends StatelessWidget {
  final HazardEvent hazard;
  const _HazardDetail({required this.hazard});

  @override
  Widget build(BuildContext context) {
    final color = hazard.riskLevel == RiskLevel.critical
        ? AppColors.critical
        : hazard.riskLevel == RiskLevel.high
            ? AppColors.high
            : AppColors.warning;

    return AppCard(
      borderColor: color.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${hazard.type.label} Hazard',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              StatusChip(label: hazard.riskLevel.label.toUpperCase(), color: color),
            ],
          ),
          Divider(height: 20, color: AppColors.navyBorder.withValues(alpha: 0.6)),
          _row('Target Zone', 'Zone ${hazard.zone}'),
          _row('Concentration', '${hazard.sensorValue} ${hazard.sensorUnit}'),
          _row('AI Confidence', '${hazard.confidencePercent.toStringAsFixed(0)}%'),
          _row('Drone Source', hazard.droneId),
          _row('Trainee Response', hazard.responseStatus),
          _row('Timestamp', '${hazard.detectedAt.hour}:${hazard.detectedAt.minute.toString().padLeft(2, '0')} UTC'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _HazardList extends StatelessWidget {
  final List<HazardEvent> hazards;
  final HazardEvent? selected;
  final ValueChanged<HazardEvent> onSelect;

  const _HazardList({
    required this.hazards,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hazard Incident Feed',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                '${hazards.length} Events',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: hazards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final h = hazards[i];
                final isCurrent = selected?.id == h.id;
                final color = h.riskLevel == RiskLevel.critical
                    ? AppColors.critical
                    : h.riskLevel == RiskLevel.high
                        ? AppColors.high
                        : AppColors.warning;

                return GestureDetector(
                  onTap: () => onSelect(h),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.surfaceElevated
                          : AppColors.navyLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? color.withValues(alpha: 0.5) : AppColors.navyBorder.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${h.type.label} — Zone ${h.zone}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${h.sensorValue} ${h.sensorUnit} • ${h.confidencePercent.toStringAsFixed(0)}% conf',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(label: h.responseStatus, color: color),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
