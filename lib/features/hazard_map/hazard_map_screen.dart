import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/core/constants/mock_data.dart';
import 'package:trainer_app/models/hazard.dart';
import 'package:trainer_app/services/simulation_service.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trainer_app/widgets/basemap_3d_panel.dart';

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlipText(
                        'Hazard Geospatial Radar',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
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

class _MapCanvas extends StatefulWidget {
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
  State<_MapCanvas> createState() => _MapCanvasState();
}

enum _HazardTileMode { basemap3d, satellite, streets }

class _MapCanvasState extends State<_MapCanvas> {
  late final MapController _mapController;
  _HazardTileMode _tileMode = _HazardTileMode.satellite;
  BasemapSettings _basemapSettings = const BasemapSettings();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _getTileUrl() {
    switch (_tileMode) {
      case _HazardTileMode.basemap3d:
        return _basemapSettings.getTileUrl();
      case _HazardTileMode.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case _HazardTileMode.streets:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  String? _getLabelOverlayUrl() {
    switch (_tileMode) {
      case _HazardTileMode.basemap3d:
        return _basemapSettings.getLabelOverlayUrl();
      case _HazardTileMode.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';
      case _HazardTileMode.streets:
        return null;
    }
  }

  List<String> _getSubdomains() {
    if (_tileMode == _HazardTileMode.basemap3d) {
      return _basemapSettings.getSubdomains();
    }
    return const [];
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
  Widget build(BuildContext context) {
    final dronePos = LatLng(
      widget.simData.telemetry.latitude,
      widget.simData.telemetry.longitude,
    );

    final showPois = _tileMode == _HazardTileMode.basemap3d && _basemapSettings.pois;
    final is3d = _tileMode == _HazardTileMode.basemap3d && _basemapSettings.is3dTilt;

    Widget mapWidget = FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(20.5942, 78.9635),
        initialZoom: 16.8,
        minZoom: 13.0,
        maxZoom: 19.0,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          key: ValueKey('${_tileMode}_${_basemapSettings.satellite}_${_basemapSettings.mapboxToken}'),
          urlTemplate: _getTileUrl(),
          subdomains: _getSubdomains(),
          userAgentPackageName: 'com.skillsense.trainer_app',
          maxZoom: 19,
        ),
        // Labels/reference overlay
        if (_getLabelOverlayUrl() != null)
          TileLayer(
            key: ValueKey('labels_${_tileMode}_${_basemapSettings.placeLabels}'),
            urlTemplate: _getLabelOverlayUrl()!,
            subdomains: _getSubdomains(),
            userAgentPackageName: 'com.skillsense.trainer_app',
            maxZoom: 19,
          ),
        // Hazard detection circle pulse rings
        CircleLayer(
          circles: widget.hazards.map((h) {
            final color = _colorFor(h.riskLevel);
            final isSelected = widget.selected?.id == h.id;
            return CircleMarker(
              point: LatLng(h.latitude, h.longitude),
              radius: isSelected ? 36 : 22,
              useRadiusInMeter: false,
              color: color.withValues(alpha: isSelected ? 0.25 : 0.12),
              borderColor: color.withValues(alpha: isSelected ? 0.9 : 0.5),
              borderStrokeWidth: isSelected ? 2.0 : 1.2,
            );
          }).toList(),
        ),
        // Marker layer: Hazards, POIs and Drone
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
            // Hazard pins
            ...widget.hazards.map((h) {
              final color = _colorFor(h.riskLevel);
              final isSelected = widget.selected?.id == h.id;

              return Marker(
                point: LatLng(h.latitude, h.longitude),
                width: 140,
                height: 52,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => widget.onSelect(h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF070B12).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isSelected ? color : color.withValues(alpha: 0.6),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: isSelected ? 0.45 : 0.2),
                              blurRadius: isSelected ? 8 : 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${h.zone} • ${h.sensorValue.toStringAsFixed(1)} ${h.sensorUnit}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontSize: 9.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Live drone location
            Marker(
              point: dronePos,
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal.withValues(alpha: 0.25),
                  border: Border.all(color: AppColors.teal, width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.navigation, color: AppColors.teal, size: 16),
                ),
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070A0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.8), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            mapWidget,

            // Atmospheric Dusk / Night Tint in 3D Basemap mode with Satellite
            if (_tileMode == _HazardTileMode.basemap3d && _basemapSettings.satellite)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: _basemapSettings.lighting == BasemapLighting.dusk
                        ? const Color(0xFF140D06).withValues(alpha: 0.35)
                        : const Color(0xFF020612).withValues(alpha: 0.46),
                  ),
                ),
              ),

            // Top Left: Layer Mode Switcher (3D Basemap, Satellite, Streets)
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
                    _layerButton(
                      label: '3D Basemap',
                      icon: Icons.view_in_ar_outlined,
                      isSelected: _tileMode == _HazardTileMode.basemap3d,
                      onTap: () => setState(() => _tileMode = _HazardTileMode.basemap3d),
                    ),
                    _layerButton(
                      label: 'Satellite',
                      icon: Icons.satellite_alt_outlined,
                      isSelected: _tileMode == _HazardTileMode.satellite,
                      onTap: () => setState(() => _tileMode = _HazardTileMode.satellite),
                    ),
                    _layerButton(
                      label: 'Streets',
                      icon: Icons.map_outlined,
                      isSelected: _tileMode == _HazardTileMode.streets,
                      onTap: () => setState(() => _tileMode = _HazardTileMode.streets),
                    ),
                  ],
                ),
              ),
            ),

            // Top Right: 3D Basemap Control Panel (Matching reference screenshot)
            if (_tileMode == _HazardTileMode.basemap3d)
              Positioned(
                top: 12,
                right: 12,
                child: BasemapControlPanel(
                  settings: _basemapSettings,
                  onChanged: (s) => setState(() => _basemapSettings = s),
                ),
              ),

            // Live feed status (shown when panel not in that spot or top center)
            if (_tileMode != _HazardTileMode.basemap3d)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B12).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PulseDot(color: AppColors.teal, size: 6),
                      const SizedBox(width: 6),
                      Text(
                        'GIS RADAR ACTIVE • ${widget.hazards.length} PINS',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Left: Severity Scale
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B12).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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

            // Bottom Right: Zoom & Center Controls
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
                    Tooltip(
                      message: 'Center Facility',
                      child: InkWell(
                        onTap: () => _mapController.move(const LatLng(20.5942, 78.9635), 16.8),
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          child: const Icon(Icons.crop_free, size: 15, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Zoom In',
                      child: InkWell(
                        onTap: () => _mapController.move(
                          _mapController.camera.center,
                          (_mapController.camera.zoom + 0.6).clamp(12.0, 19.0),
                        ),
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          child: const Icon(Icons.add, size: 15, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Zoom Out',
                      child: InkWell(
                        onTap: () => _mapController.move(
                          _mapController.camera.center,
                          (_mapController.camera.zoom - 0.6).clamp(12.0, 19.0),
                        ),
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          child: const Icon(Icons.remove, size: 15, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _layerButton({
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
            Icon(icon, size: 12, color: isSelected ? AppColors.teal : AppColors.textSecondary),
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
