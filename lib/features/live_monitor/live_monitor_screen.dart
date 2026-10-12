import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/models/hazard.dart';
import 'package:trainer_app/models/telemetry.dart';
import 'package:trainer_app/services/simulation_service.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trainer_app/widgets/basemap_3d_panel.dart';

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
                  FlipText(
                    'Mission Cockpit',
                    style: const TextStyle(
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
              AnimatedButton(
                onPressed: () =>
                    ref.read(simulationProvider.notifier).startMission(),
                icon: Icons.play_arrow,
                text: 'Start Mission',
                variant: AnimatedButtonVariant.primary,
                height: 42,
              ),
            if (isRunning)
              AnimatedButton(
                onPressed: () =>
                    ref.read(simulationProvider.notifier).injectHazard(),
                icon: Icons.bolt,
                text: 'Inject Hazard',
                variant: AnimatedButtonVariant.critical,
                height: 42,
              ),
            if (isRunning)
              AnimatedButton(
                onPressed: () =>
                    ref.read(simulationProvider.notifier).pauseMission(),
                icon: Icons.pause,
                text: 'Pause',
                variant: AnimatedButtonVariant.warning,
                height: 42,
              ),
            if (isPaused)
              AnimatedButton(
                onPressed: () =>
                    ref.read(simulationProvider.notifier).resumeMission(),
                icon: Icons.play_arrow,
                text: 'Resume',
                variant: AnimatedButtonVariant.primary,
                height: 42,
              ),
            if (isRunning || isPaused)
              AnimatedButton(
                onPressed: () =>
                    ref.read(simulationProvider.notifier).stopMission(),
                icon: Icons.stop,
                text: 'Stop (RTH)',
                variant: AnimatedButtonVariant.critical,
                height: 42,
              ),
            AnimatedButton(
              onPressed: () =>
                  ref.read(simulationProvider.notifier).resetMission(),
              icon: Icons.refresh,
              text: 'Reset',
              variant: AnimatedButtonVariant.outline,
              height: 42,
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
            height: 390,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF090D15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RealGisMapView(sim: sim),
            ),
          ),
        ],
      ),
    );
  }
}

enum MapTileSource { basemap3d, satellite, streets }

class _WaypointData {
  final LatLng point;
  final String label;
  final String code;
  final bool isBase;
  const _WaypointData({
    required this.point,
    required this.label,
    required this.code,
    this.isBase = false,
  });
}

class RealGisMapView extends StatefulWidget {
  final SimulationData sim;
  const RealGisMapView({super.key, required this.sim});

  @override
  State<RealGisMapView> createState() => _RealGisMapViewState();
}

class _RealGisMapViewState extends State<RealGisMapView> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseAnim;
  MapTileSource _tileSource = MapTileSource.satellite;
  BasemapSettings _basemapSettings = const BasemapSettings();
  bool _autoFollow = true;

  static const _waypoints = [
    _WaypointData(
      point: LatLng(20.5937, 78.9629),
      label: 'BASE DOCK',
      code: 'WP-0',
      isBase: true,
    ),
    _WaypointData(
      point: LatLng(20.5940, 78.9631),
      label: 'ZONE A (STORAGE)',
      code: 'WP-1',
    ),
    _WaypointData(
      point: LatLng(20.5943, 78.9634),
      label: 'ZONE B (PIPE GALLERY)',
      code: 'WP-2',
    ),
    _WaypointData(
      point: LatLng(20.5946, 78.9637),
      label: 'ZONE C (WELDING)',
      code: 'WP-3',
    ),
    _WaypointData(
      point: LatLng(20.5942, 78.9641),
      label: 'INSPECTION CORRIDOR',
      code: 'WP-4',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant RealGisMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoFollow &&
        (oldWidget.sim.telemetry.latitude != widget.sim.telemetry.latitude ||
            oldWidget.sim.telemetry.longitude != widget.sim.telemetry.longitude)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            _mapController.move(
              LatLng(widget.sim.telemetry.latitude, widget.sim.telemetry.longitude),
              _mapController.camera.zoom,
            );
          } catch (_) {}
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String _getTileUrl() {
    switch (_tileSource) {
      case MapTileSource.basemap3d:
        return _basemapSettings.getTileUrl();
      case MapTileSource.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapTileSource.streets:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  List<String> _getSubdomains() {
    if (_tileSource == MapTileSource.basemap3d) {
      return _basemapSettings.getSubdomains();
    }
    return const [];
  }

  String? _getLabelOverlayUrl() {
    switch (_tileSource) {
      case MapTileSource.basemap3d:
        return _basemapSettings.getLabelOverlayUrl();
      case MapTileSource.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';
      case MapTileSource.streets:
        return null;
    }
  }

  void _zoomIn() {
    try {
      final newZoom = (_mapController.camera.zoom + 0.6).clamp(12.0, 19.0);
      _mapController.move(_mapController.camera.center, newZoom);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final newZoom = (_mapController.camera.zoom - 0.6).clamp(12.0, 19.0);
      _mapController.move(_mapController.camera.center, newZoom);
    } catch (_) {}
  }

  void _centerDrone() {
    try {
      _mapController.move(
        LatLng(widget.sim.telemetry.latitude, widget.sim.telemetry.longitude),
        17.4,
      );
      setState(() => _autoFollow = true);
    } catch (_) {}
  }

  void _fitFacility() {
    try {
      _mapController.move(const LatLng(20.5942, 78.9635), 17.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final dronePos = LatLng(widget.sim.telemetry.latitude, widget.sim.telemetry.longitude);
    final routePoints = _waypoints.map((w) => w.point).toList();
    final hasHazard = widget.sim.hazardInjected || widget.sim.activeHazard != null;
    final hazardPos = const LatLng(20.5946, 78.9637);
    final showPois = _tileSource == MapTileSource.basemap3d && _basemapSettings.pois;
    final is3d = _tileSource == MapTileSource.basemap3d && _basemapSettings.is3dTilt;

    Widget mapWidget = FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(20.5942, 78.9635),
        initialZoom: 17.2,
        minZoom: 13.0,
        maxZoom: 19.0,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          key: ValueKey('${_tileSource}_${_basemapSettings.satellite}_${_basemapSettings.mapboxToken}'),
          urlTemplate: _getTileUrl(),
          subdomains: _getSubdomains(),
          userAgentPackageName: 'com.skillsense.trainer_app',
          maxZoom: 19,
        ),
        // Labels/reference overlay
        if (_getLabelOverlayUrl() != null)
          TileLayer(
            key: ValueKey('labels_${_tileSource}_${_basemapSettings.placeLabels}'),
            urlTemplate: _getLabelOverlayUrl()!,
            subdomains: _getSubdomains(),
            userAgentPackageName: 'com.skillsense.trainer_app',
            maxZoom: 19,
          ),
        // Mission flight path polylines
        PolylineLayer(
          polylines: [
            // Outer glow shadow
            Polyline(
              points: routePoints,
              strokeWidth: 6.0,
              color: AppColors.teal.withValues(alpha: 0.25),
            ),
            // Sharp main route
            Polyline(
              points: routePoints,
              strokeWidth: 2.8,
              color: AppColors.teal,
              borderStrokeWidth: 1.2,
              borderColor: const Color(0xFF00382E),
            ),
          ],
        ),
        // Hazard radius zone
        if (hasHazard)
          CircleLayer(
            circles: [
              CircleMarker(
                point: hazardPos,
                radius: 38,
                useRadiusInMeter: false,
                color: AppColors.critical.withValues(alpha: 0.22),
                borderColor: AppColors.critical,
                borderStrokeWidth: 2.0,
              ),
            ],
          ),
        // Waypoints, POIs & Drone Marker
        MarkerLayer(
          markers: [
            // Reference POIs with pill style from screenshot
            if (showPois)
              ...BasemapPoi.facilityPois.map((p) {
                return Marker(
                  point: p.point,
                  width: 145,
                  height: 30,
                  alignment: Alignment.center,
                  child: BasemapPoiPill(
                    poi: p,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${p.name} • ${p.category} Area Active'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF0F1523),
                        ),
                      );
                    },
                  ),
                );
              }),
                // Waypoint markers
                ..._waypoints.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final wp = entry.value;
                  final isCurrent = widget.sim.waypointIndex == idx;

                  return Marker(
                    point: wp.point,
                    width: 135,
                    height: 48,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Waypoint chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF070B12).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.teal
                                  : AppColors.navyBorder.withValues(alpha: 0.9),
                              width: isCurrent ? 1.5 : 1.0,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.teal.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent ? AppColors.teal : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  wp.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isCurrent ? AppColors.teal : const Color(0xFF94A3B8),
                                    fontSize: 9.5,
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Node dot
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent ? AppColors.teal : const Color(0xFF334155),
                            border: Border.all(
                              color: const Color(0xFF0F172A),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Hazard badge marker
                if (hasHazard)
                  Marker(
                    point: hazardPos,
                    width: 150,
                    height: 52,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D0D12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.critical, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.critical.withValues(alpha: 0.45),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'GAS LEAK • ${widget.sim.telemetry.gasPpm.toStringAsFixed(1)} PPM',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Live drone marker
                Marker(
                  point: dronePos,
                  width: 90,
                  height: 90,
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) {
                      final wave = _pulseAnim.value;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radar pulse ring
                          Container(
                            width: 32 + (wave * 34),
                            height: 32 + (wave * 34),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.teal.withValues(alpha: (1.0 - wave) * 0.7),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Tactical halo
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.teal.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppColors.teal.withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Drone Core icon
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.teal,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF00F0B5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.navigation,
                              size: 13,
                              color: Color(0xFF05080E),
                            ),
                          ),
                          // Drone callout pill
                          Positioned(
                            bottom: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: AppColors.teal.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'DRONE-01 • ${widget.sim.telemetry.altitudeM.toStringAsFixed(1)}m',
                                style: const TextStyle(
                                  color: AppColors.teal,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );

        if (is3d) {
          mapWidget = ClipRect(
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0014)
                ..rotateX(0.42),
              alignment: FractionalOffset.center,
              child: mapWidget,
            ),
          );
        }

        return Stack(
          children: [
            mapWidget,

            // Atmospheric Dusk / Night Tint in 3D Basemap mode with Satellite
            if (_tileSource == MapTileSource.basemap3d && _basemapSettings.satellite)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: _basemapSettings.lighting == BasemapLighting.dusk
                        ? const Color(0xFF140D06).withValues(alpha: 0.35)
                        : const Color(0xFF020612).withValues(alpha: 0.46),
                  ),
                ),
              ),

            // TOP LEFT: Map Layer Switcher (3D Basemap, Satellite, Streets)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B12).withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLayerButton(
                      label: '3D Basemap',
                      icon: Icons.view_in_ar_outlined,
                      isSelected: _tileSource == MapTileSource.basemap3d,
                      onTap: () => setState(() => _tileSource = MapTileSource.basemap3d),
                    ),
                    _buildLayerButton(
                      label: 'Satellite Recon',
                      icon: Icons.satellite_alt_outlined,
                      isSelected: _tileSource == MapTileSource.satellite,
                      onTap: () => setState(() => _tileSource = MapTileSource.satellite),
                    ),
                    _buildLayerButton(
                      label: 'Streets',
                      icon: Icons.map_outlined,
                      isSelected: _tileSource == MapTileSource.streets,
                      onTap: () => setState(() => _tileSource = MapTileSource.streets),
                    ),
                  ],
                ),
              ),
            ),

            // TOP RIGHT: 3D Basemap Control Panel or Live GIS Feed Badge
            if (_tileSource == MapTileSource.basemap3d)
              Positioned(
                top: 12,
                right: 12,
                child: BasemapControlPanel(
                  settings: _basemapSettings,
                  onChanged: (s) => setState(() => _basemapSettings = s),
                ),
              )
            else
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B12).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.teal,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00F0B5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'REAL-TIME GIS FEED • 10Hz TELEMETRY',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

        // BOTTOM LEFT: GPS Telemetry Readout
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF070B12).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.my_location, color: AppColors.teal, size: 12),
                const SizedBox(width: 6),
                Text(
                  '${widget.sim.telemetry.latitude.toStringAsFixed(4)}°N  ${widget.sim.telemetry.longitude.toStringAsFixed(4)}°E',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  ALT: ${widget.sim.telemetry.altitudeM.toStringAsFixed(1)}m  •  SPD: 4.8 m/s',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),

        // BOTTOM RIGHT: Interactive Map Action Buttons
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF070B12).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapAction(
                  icon: _autoFollow ? Icons.gps_fixed : Icons.gps_not_fixed,
                  tooltip: _autoFollow ? 'Locking on Drone' : 'Follow Drone',
                  color: _autoFollow ? AppColors.teal : AppColors.textSecondary,
                  onTap: _centerDrone,
                ),
                const SizedBox(width: 2),
                _buildMapAction(
                  icon: Icons.crop_free,
                  tooltip: 'Fit Facility',
                  color: AppColors.textSecondary,
                  onTap: _fitFacility,
                ),
                const SizedBox(width: 2),
                _buildMapAction(
                  icon: Icons.add,
                  tooltip: 'Zoom In',
                  color: AppColors.textSecondary,
                  onTap: _zoomIn,
                ),
                const SizedBox(width: 2),
                _buildMapAction(
                  icon: Icons.remove,
                  tooltip: 'Zoom Out',
                  color: AppColors.textSecondary,
                  onTap: _zoomOut,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayerButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? AppColors.teal : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapAction({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
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
                points.last['y']!.toStringAsFixed(1),
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
