import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/models/hazard.dart';
import 'package:trainer_app/models/telemetry.dart';
import 'package:trainer_app/services/simulation_service.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:fl_chart/fl_chart.dart';

class LiveMonitorScreen extends ConsumerWidget {
  const LiveMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sim = ref.watch(simulationProvider);
    final t = sim.telemetry;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeSlideEntrance(
        child: Column(
          children: [
            // Hazard alert banner
            if (sim.activeHazard != null)
              _HazardAlertBanner(hazard: sim.activeHazard!, ref: ref),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 960;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PageHeader(sim: sim, ref: ref),
                      const SizedBox(height: 20),
                      _DroneStatusBar(telemetry: t),
                      const SizedBox(height: 20),
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _MapArea(sim: sim)),
                                const SizedBox(width: 20),
                                Expanded(flex: 2, child: _SensorPanel(sim: sim)),
                              ],
                            )
                          : Column(
                              children: [
                                _MapArea(sim: sim),
                                const SizedBox(height: 20),
                                _SensorPanel(sim: sim),
                              ],
                            ),
                      const SizedBox(height: 20),
                      _SensorCharts(sim: sim),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final SimulationData sim;
  final WidgetRef ref;
  const _PageHeader({required this.sim, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isRunning = sim.state == SimulationState.running ||
        sim.state == SimulationState.hazardPhase;
    final isPaused = sim.state == SimulationState.paused;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Mission Cockpit',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(width: 10),
                  StatusChip(
                    label: sim.state.name.toUpperCase(),
                    color: sim.state == SimulationState.running
                        ? AppColors.safe
                        : sim.state == SimulationState.hazardPhase
                            ? AppColors.critical
                            : sim.state == SimulationState.paused
                                ? AppColors.warning
                                : AppColors.textSecondary,
                    hasPulse: isRunning,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Autonomous flight telemetry stream, multi-gas sensor diagnostics & manual hazard trigger',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        // Mission controls
        Wrap(
          spacing: 10,
          children: [
            if (!isRunning && !isPaused)
              ElevatedButton.icon(
                onPressed: () => ref.read(simulationProvider.notifier).startMission(),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Start Mission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safe,
                  foregroundColor: const Color(0xFF080A0F),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
              ),
            if (isRunning)
              ElevatedButton.icon(
                onPressed: () => ref.read(simulationProvider.notifier).injectHazard(),
                icon: const Icon(Icons.bolt, size: 16),
                label: const Text('Inject Hazard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.critical,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
              ),
            if (isRunning)
              OutlinedButton.icon(
                onPressed: () => ref.read(simulationProvider.notifier).pauseMission(),
                icon: const Icon(Icons.pause, size: 16),
                label: const Text('Pause'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
              ),
            if (isPaused)
              ElevatedButton.icon(
                onPressed: () => ref.read(simulationProvider.notifier).resumeMission(),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: const Color(0xFF080A0F),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
              ),
            if (isRunning || isPaused)
              OutlinedButton.icon(
                onPressed: () => ref.read(simulationProvider.notifier).stopMission(),
                icon: const Icon(Icons.stop, size: 16),
                label: const Text('Stop (RTH)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.critical,
                  side: BorderSide(color: AppColors.critical.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => ref.read(simulationProvider.notifier).resetMission(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.7)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DroneStatusBar extends StatelessWidget {
  final TelemetryReading telemetry;
  const _DroneStatusBar({required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.flight, color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'DRONE-01',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '•  Alpha-1 Quadcopter',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  PulseDot(color: AppColors.safe, size: 5),
                  SizedBox(width: 5),
                  Text(
                    'Telemetry Uplink Active',
                    style: TextStyle(color: AppColors.safe, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _DroneMetric(
                  icon: Icons.battery_charging_full,
                  label: 'Battery Level',
                  value: '${telemetry.batteryPercent}%',
                  color: telemetry.batteryPercent > 40 ? AppColors.safe : AppColors.warning,
                ),
                _DroneMetric(
                  icon: Icons.gps_fixed,
                  label: 'RTK Positioning',
                  value: 'Locked (12 Sats)',
                  color: AppColors.teal,
                ),
                _DroneMetric(
                  icon: Icons.cell_tower,
                  label: 'Radio Link',
                  value: '${telemetry.signalStrength}% (-62 dBm)',
                  color: AppColors.blue,
                ),
                _DroneMetric(
                  icon: Icons.height,
                  label: 'Barometric Altitude',
                  value: '${telemetry.altitudeM.toStringAsFixed(1)} m AGL',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DroneMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DroneMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Simulated Map Area ────────────────────────────────────────────────────────

class _MapArea extends StatelessWidget {
  final SimulationData sim;
  const _MapArea({required this.sim});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mission Waypoint Path',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Automated drone sweep over facility zones',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                StatusChip(
                  label: sim.state.name.toUpperCase(),
                  color: sim.state == SimulationState.running
                      ? AppColors.safe
                      : sim.state == SimulationState.hazardPhase
                          ? AppColors.critical
                          : sim.state == SimulationState.paused
                              ? AppColors.warning
                              : AppColors.textSecondary,
                  hasPulse: sim.state == SimulationState.running,
                ),
              ],
            ),
          ),
          Container(
            height: 330,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF090D15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _SimulatedMapView(sim: sim),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulatedMapView extends StatelessWidget {
  final SimulationData sim;
  const _SimulatedMapView({required this.sim});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(sim: sim),
      child: Stack(
        children: [
          // GPS coordinates overlay
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.my_location, color: AppColors.teal, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    '${sim.telemetry.latitude.toStringAsFixed(4)}°N  ${sim.telemetry.longitude.toStringAsFixed(4)}°E',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Disclaimer
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SIMULATED TELEMETRY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final SimulationData sim;
  _MapPainter({required this.sim});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF090D15);
    canvas.drawRect(Offset.zero & size, bg);

    // Subtle tactical grid
    final gridPaint = Paint()
      ..color = const Color(0xFF131924)
      ..strokeWidth = 1;
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * i / 6, 0),
        Offset(size.width * i / 6, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 5),
        Offset(size.width, size.height * i / 5),
        gridPaint,
      );
    }

    // Zone labels
    const txtStyle = TextStyle(color: Color(0xFF334155), fontSize: 11, fontWeight: FontWeight.w600);
    _drawLabel(canvas, 'ZONE A (STORAGE)', Offset(size.width * 0.15, size.height * 0.18), txtStyle);
    _drawLabel(canvas, 'ZONE B (PIPE GALLERY)', Offset(size.width * 0.48, size.height * 0.18), txtStyle);
    _drawLabel(canvas, 'ZONE C (WELDING)', Offset(size.width * 0.78, size.height * 0.18), txtStyle);
    _drawLabel(canvas, 'BASE DOCK', Offset(size.width * 0.08, size.height * 0.78), txtStyle);

    // Mission path
    final pathPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final waypoints = [
      Offset(size.width * 0.12, size.height * 0.82),
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.50, size.height * 0.30),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.65),
    ];
    final path = Path()..moveTo(waypoints[0].dx, waypoints[0].dy);
    for (final wp in waypoints.skip(1)) {
      path.lineTo(wp.dx, wp.dy);
    }
    canvas.drawPath(path, pathPaint);

    // Waypoint nodes
    final wpPaint = Paint()..color = AppColors.teal.withValues(alpha: 0.6);
    for (final wp in waypoints) {
      canvas.drawCircle(wp, 4, wpPaint);
    }

    // Drone position
    final idx = sim.waypointIndex.clamp(0, waypoints.length - 1);
    final dronePos = waypoints[idx];
    _drawDrone(canvas, dronePos);

    // Hazard marker
    if (sim.hazardInjected || sim.activeHazard != null) {
      _drawHazard(canvas, waypoints[2], AppColors.critical);
    }
  }

  void _drawDrone(Canvas canvas, Offset pos) {
    canvas.drawCircle(pos, 12, Paint()..color = AppColors.teal.withValues(alpha: 0.2));
    canvas.drawCircle(pos, 7, Paint()..color = AppColors.teal);
    final iconPaint = Paint()
      ..color = const Color(0xFF080A0F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pos + const Offset(-4, -4), pos + const Offset(4, 4), iconPaint);
    canvas.drawLine(pos + const Offset(4, -4), pos + const Offset(-4, 4), iconPaint);
  }

  void _drawHazard(Canvas canvas, Offset pos, Color color) {
    canvas.drawCircle(pos, 26, Paint()..color = color.withValues(alpha: 0.15));
    canvas.drawCircle(pos, 16, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawCircle(pos, 8, Paint()..color = color.withValues(alpha: 0.8));
    final outline = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(pos, 26, outline);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, TextStyle style) {
    final span = TextSpan(text: text, style: style);
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.sim != sim;
}

// ── Sensor Panel ──────────────────────────────────────────────────────────────

class _SensorPanel extends StatelessWidget {
  final SimulationData sim;
  const _SensorPanel({required this.sim});

  @override
  Widget build(BuildContext context) {
    final t = sim.telemetry;
    final gasColor = t.gasPpm >= 8
        ? AppColors.critical
        : t.gasPpm >= 5
            ? AppColors.high
            : t.gasPpm >= 3
                ? AppColors.warning
                : AppColors.safe;

    return Column(
      children: [
        _SensorCard(
          label: 'Gas Concentration',
          value: '${t.gasPpm.toStringAsFixed(2)} ppm',
          icon: Icons.cloud_outlined,
          color: gasColor,
          subtitle: t.gasPpm >= 8
              ? 'CRITICAL SPIKE'
              : t.gasPpm >= 5
                  ? 'HIGH'
                  : t.gasPpm >= 3
                      ? 'WARNING'
                      : 'SAFE BASELINE',
        ),
        const SizedBox(height: 12),
        _SensorCard(
          label: 'Ambient Temperature',
          value: '${t.temperatureC.toStringAsFixed(1)} °C',
          icon: Icons.thermostat_outlined,
          color: AppColors.blue,
          subtitle: t.temperatureC > 40 ? 'ELEVATED' : 'NOMINAL',
        ),
        const SizedBox(height: 12),
        _SensorCard(
          label: 'Relative Humidity',
          value: '${t.humidityPercent.toStringAsFixed(1)}%',
          icon: Icons.water_drop_outlined,
          color: AppColors.teal,
          subtitle: 'NOMINAL',
        ),
        const SizedBox(height: 12),
        _SensorCard(
          label: 'Air Quality Index (AQI)',
          value: t.airQualityIndex.toStringAsFixed(0),
          icon: Icons.air_outlined,
          color: t.airQualityIndex > 70 ? AppColors.safe : AppColors.warning,
          subtitle: t.airQualityIndex > 70 ? 'GOOD' : 'MODERATE',
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Diagnostic Neural Classifier',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.aiPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'MODEL v2.4',
                      style: TextStyle(color: AppColors.aiPurple, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (t.hazardDetected)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const PulseDot(color: AppColors.critical, size: 8),
                        const SizedBox(width: 8),
                        const Text(
                          'POSITIVE HAZARD DETECTED',
                          style: TextStyle(
                            color: AppColors.critical,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Neural Confidence: ${(t.confidence * 100).toStringAsFixed(0)}%  •  Severity: ${t.riskLevel.toUpperCase()}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                )
              else
                const Row(
                  children: [
                    PulseDot(color: AppColors.safe, size: 8),
                    SizedBox(width: 8),
                    Text(
                      'All Sensor Streams Clear — No Anomalies',
                      style: TextStyle(
                        color: AppColors.safe,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _SensorCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(label: subtitle, color: color),
        ],
      ),
    );
  }
}

// ── Live Charts ───────────────────────────────────────────────────────────────

class _SensorCharts extends StatelessWidget {
  final SimulationData sim;
  const _SensorCharts({required this.sim});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Live High-Frequency Sensor Stream',
            subtitle: '1-second interval rolling telemetry window (Gas PPM, Temperature & Humidity)',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 760;
            return isWide
                ? Row(
                    children: [
                      Expanded(
                        child: _ChartWidget(
                          points: sim.gasHistory,
                          label: 'Gas Concentration (ppm)',
                          color: AppColors.critical,
                          warningLine: 5.0,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _ChartWidget(
                          points: sim.tempHistory,
                          label: 'Ambient Temp (°C)',
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _ChartWidget(
                          points: sim.humidityHistory,
                          label: 'Relative Humidity (%)',
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _ChartWidget(
                        points: sim.gasHistory,
                        label: 'Gas Concentration (ppm)',
                        color: AppColors.critical,
                        warningLine: 5.0,
                      ),
                      const SizedBox(height: 16),
                      _ChartWidget(
                        points: sim.tempHistory,
                        label: 'Ambient Temp (°C)',
                        color: AppColors.blue,
                      ),
                    ],
                  );
          }),
        ],
      ),
    );
  }
}

class _ChartWidget extends StatelessWidget {
  final List<Map<String, double>> points;
  final String label;
  final Color color;
  final double? warningLine;

  const _ChartWidget({
    required this.points,
    required this.label,
    required this.color,
    this.warningLine,
  });

  @override
  Widget build(BuildContext context) {
    final spots = points.isEmpty
        ? [const FlSpot(0, 0)]
        : points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['y']!)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (points.isNotEmpty)
              Text(
                '${points.last['y']!.toStringAsFixed(1)}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 110,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.navyLight.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.5)),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: warningLine != null
                  ? ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                        y: warningLine!,
                        color: AppColors.warning.withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ])
                  : ExtraLinesData(),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: color,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hazard Alert Banner ───────────────────────────────────────────────────────

class _HazardAlertBanner extends StatelessWidget {
  final HazardEvent hazard;
  final WidgetRef ref;
  const _HazardAlertBanner({required this.hazard, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(color: AppColors.critical.withValues(alpha: 0.4), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.critical.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'CRITICAL HAZARD DETECTED',
                      style: TextStyle(
                        color: AppColors.critical,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatusChip(
                      label: hazard.riskLevel.label.toUpperCase(),
                      color: AppColors.critical,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Zone ${hazard.zone}  •  ${hazard.type.label} concentration spike at ${hazard.sensorValue.toStringAsFixed(1)} ppm  •  Confidence ${hazard.confidencePercent.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref.read(simulationProvider.notifier).acknowledgeHazard(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Acknowledge'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.critical,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Start Trainee Assessment'),
          ),
        ],
      ),
    );
  }
}
