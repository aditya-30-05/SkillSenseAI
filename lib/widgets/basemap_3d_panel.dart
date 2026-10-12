import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../app/theme.dart';

enum BasemapLighting { dusk, night }

enum BasemapTheme {
  defaultTheme,
  faded,
  mono,
  ocean,
  warm,
  vivid,
}

class BasemapSettings {
  final BasemapLighting lighting;
  final BasemapTheme theme;
  final bool satellite;
  final bool placeLabels;
  final bool pois;
  final bool is3dTilt;
  final String mapboxToken;

  const BasemapSettings({
    this.lighting = BasemapLighting.dusk,
    this.theme = BasemapTheme.warm,
    this.satellite = true,
    this.placeLabels = true,
    this.pois = true,
    this.is3dTilt = true,
    this.mapboxToken = '',
  });

  BasemapSettings copyWith({
    BasemapLighting? lighting,
    BasemapTheme? theme,
    bool? satellite,
    bool? placeLabels,
    bool? pois,
    bool? is3dTilt,
    String? mapboxToken,
  }) {
    return BasemapSettings(
      lighting: lighting ?? this.lighting,
      theme: theme ?? this.theme,
      satellite: satellite ?? this.satellite,
      placeLabels: placeLabels ?? this.placeLabels,
      pois: pois ?? this.pois,
      is3dTilt: is3dTilt ?? this.is3dTilt,
      mapboxToken: mapboxToken ?? this.mapboxToken,
    );
  }

  /// Primary tile URL
  String getTileUrl() {
    if (mapboxToken.isNotEmpty) {
      final style = satellite ? 'satellite-streets-v12' : 'dark-v11';
      return 'https://api.mapbox.com/styles/v1/mapbox/$style/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken';
    }
    if (satellite) {
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
    return 'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}@2x.png';
  }

  /// Labels overlay URL
  String? getLabelOverlayUrl() {
    if (mapboxToken.isNotEmpty) return null; // Mapbox raster styles include labels
    if (!placeLabels) return null;
    if (satellite) {
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';
    }
    return 'https://{s}.basemaps.cartocdn.com/dark_only_labels/{z}/{x}/{y}@2x.png';
  }

  List<String> getSubdomains() {
    if (mapboxToken.isEmpty && !satellite) {
      return const ['a', 'b', 'c', 'd'];
    }
    return const [];
  }
}

class BasemapPoi {
  final String id;
  final String name;
  final String category;
  final LatLng point;
  final IconData icon;
  final Color color;

  const BasemapPoi({
    required this.id,
    required this.name,
    required this.category,
    required this.point,
    required this.icon,
    required this.color,
  });

  /// Reference POIs centered around facility area (20.5942, 78.9635)
  static const List<BasemapPoi> facilityPois = [
    BasemapPoi(
      id: 'poi-park-1',
      name: 'West Green Buffer',
      category: 'Park',
      point: LatLng(20.5936, 78.9621),
      icon: Icons.park,
      color: Color(0xFF22C55E),
    ),
    BasemapPoi(
      id: 'poi-park-2',
      name: 'Battery Eco Reserve',
      category: 'Park',
      point: LatLng(20.5931, 78.9627),
      icon: Icons.park,
      color: Color(0xFF22C55E),
    ),
    BasemapPoi(
      id: 'poi-hub-1',
      name: 'Central Command Tower',
      category: 'Hub',
      point: LatLng(20.5951, 78.9632),
      icon: Icons.account_balance,
      color: Color(0xFFF472B6),
    ),
    BasemapPoi(
      id: 'poi-dock-1',
      name: 'Ground Stn & Base Dock',
      category: 'Terminal',
      point: LatLng(20.5937, 78.9629),
      icon: Icons.directions_boat,
      color: Color(0xFF38BDF8),
    ),
    BasemapPoi(
      id: 'poi-dock-2',
      name: 'South Heliport & Terminal',
      category: 'Terminal',
      point: LatLng(20.5929, 78.9641),
      icon: Icons.flight,
      color: Color(0xFF38BDF8),
    ),
    BasemapPoi(
      id: 'poi-gas-1',
      name: 'Pipe Gallery Valve Hub',
      category: 'Industrial',
      point: LatLng(20.5945, 78.9645),
      icon: Icons.restaurant,
      color: Color(0xFFFBBF24),
    ),
    BasemapPoi(
      id: 'poi-sec-1',
      name: 'Perimeter Radar Alpha',
      category: 'Security',
      point: LatLng(20.5949, 78.9624),
      icon: Icons.hotel,
      color: Color(0xFFA78BFA),
    ),
  ];
}

/// Floating 3D Basemap Control Panel matching reference image
class BasemapControlPanel extends StatefulWidget {
  final BasemapSettings settings;
  final ValueChanged<BasemapSettings> onChanged;

  const BasemapControlPanel({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  State<BasemapControlPanel> createState() => _BasemapControlPanelState();
}

class _BasemapControlPanelState extends State<BasemapControlPanel> {
  bool _isCollapsed = false;

  void _showTokenDialog() {
    final controller = TextEditingController(text: widget.settings.mapboxToken);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1523),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF1E2837)),
        ),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_outlined, color: AppColors.teal, size: 20),
            SizedBox(width: 8),
            Text(
              'Mapbox Access Token',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currently using high-performance Dark 3D tiles with zero API key required.\n\nTo load custom Mapbox vector styles, paste your public token (starts with pk.):',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'pk.eyJ1IjoieW91ci11c2VybmFtZSI...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF080C14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E2837)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onChanged(widget.settings.copyWith(mapboxToken: ''));
              Navigator.pop(ctx);
            },
            child: const Text('Reset (Zero Key)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              widget.onChanged(widget.settings.copyWith(mapboxToken: controller.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Apply Token', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCollapsed) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F19).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E2837)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.layers_outlined, color: AppColors.teal, size: 20),
          tooltip: 'Expand 3D Basemap Controls',
          onPressed: () => setState(() => _isCollapsed = false),
        ),
      );
    }

    final s = widget.settings;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2837)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Dusk / Night & Collapse
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05080E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1A2230)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _lightingButton(
                          label: 'Dusk',
                          icon: Icons.wb_twilight_outlined,
                          isSelected: s.lighting == BasemapLighting.dusk,
                          onTap: () => widget.onChanged(s.copyWith(lighting: BasemapLighting.dusk)),
                        ),
                      ),
                      Expanded(
                        child: _lightingButton(
                          label: 'Night',
                          icon: Icons.nightlight_outlined,
                          isSelected: s.lighting == BasemapLighting.night,
                          onTap: () => widget.onChanged(s.copyWith(lighting: BasemapLighting.night)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => setState(() => _isCollapsed = true),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05080E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF1A2230)),
                  ),
                  child: const Icon(Icons.close, color: AppColors.textSecondary, size: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // COLOR THEME header
          const Text(
            'COLOR THEME',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),

          // 2x3 Grid of Theme Cards
          Row(
            children: [
              Expanded(
                child: _themeCard(
                  name: 'Default',
                  theme: BasemapTheme.defaultTheme,
                  dots: const [Color(0xFF3B82F6), Color(0xFFFFFFFF), Color(0xFF10B981)],
                  isSelected: s.theme == BasemapTheme.defaultTheme,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _themeCard(
                  name: 'Faded',
                  theme: BasemapTheme.faded,
                  dots: const [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFFCBD5E1)],
                  isSelected: s.theme == BasemapTheme.faded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _themeCard(
                  name: 'Mono',
                  theme: BasemapTheme.mono,
                  dots: const [Color(0xFFFFFFFF), Color(0xFF94A3B8), Color(0xFF475569)],
                  isSelected: s.theme == BasemapTheme.mono,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _themeCard(
                  name: 'Ocean',
                  theme: BasemapTheme.ocean,
                  dots: const [Color(0xFF06B6D4), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                  isSelected: s.theme == BasemapTheme.ocean,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _themeCard(
                  name: 'Warm',
                  theme: BasemapTheme.warm,
                  dots: const [Color(0xFFF59E0B), Color(0xFFEA580C), Color(0xFFFBBF24)],
                  isSelected: s.theme == BasemapTheme.warm,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _themeCard(
                  name: 'Vivid',
                  theme: BasemapTheme.vivid,
                  dots: const [Color(0xFFEF4444), Color(0xFF22C55E), Color(0xFF3B82F6)],
                  isSelected: s.theme == BasemapTheme.vivid,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // VIEW options header
          const Text(
            'VIEW',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),

          _viewSwitch(
            icon: Icons.language,
            label: 'Satellite',
            value: s.satellite,
            onChanged: (v) => widget.onChanged(s.copyWith(satellite: v)),
          ),
          _viewSwitch(
            icon: Icons.title,
            label: 'Place Labels',
            value: s.placeLabels,
            onChanged: (v) => widget.onChanged(s.copyWith(placeLabels: v)),
          ),
          _viewSwitch(
            icon: Icons.star_border,
            label: 'Points of Interest',
            value: s.pois,
            onChanged: (v) => widget.onChanged(s.copyWith(pois: v)),
          ),
          _viewSwitch(
            icon: Icons.view_in_ar,
            label: '3D Perspective Tilt',
            value: s.is3dTilt,
            onChanged: (v) => widget.onChanged(s.copyWith(is3dTilt: v)),
          ),

          const SizedBox(height: 8),

          // Mapbox token button
          InkWell(
            onTap: _showTokenDialog,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF05080E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: s.mapboxToken.isNotEmpty ? AppColors.teal : const Color(0xFF1E2837),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    s.mapboxToken.isNotEmpty ? Icons.check_circle_outline : Icons.key_outlined,
                    size: 13,
                    color: s.mapboxToken.isNotEmpty ? AppColors.teal : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.mapboxToken.isNotEmpty ? 'Custom Mapbox Active' : 'Mapbox Token (Optional)',
                      style: TextStyle(
                        color: s.mapboxToken.isNotEmpty ? AppColors.teal : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lightingButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF182232) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: const Color(0xFF2E3D52))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeCard({
    required String name,
    required BasemapTheme theme,
    required List<Color> dots,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => widget.onChanged(widget.settings.copyWith(theme: theme)),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF161F2C) : const Color(0xFF05080E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1A2230),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dots.map((d) {
                return Container(
                  width: 5.5,
                  height: 5.5,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: d),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            Text(
              name,
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

  Widget _viewSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.68,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveThumbColor: AppColors.textSecondary,
              inactiveTrackColor: const Color(0xFF1E2837),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill marker for Points of Interest (POIs) matching reference screenshot
class BasemapPoiPill extends StatelessWidget {
  final BasemapPoi poi;
  final VoidCallback? onTap;

  const BasemapPoiPill({
    super.key,
    required this.poi,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16).withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: poi.color.withValues(alpha: 0.65),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: poi.color.withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: poi.color,
              ),
              child: Center(
                child: Icon(
                  poi.icon,
                  size: 9,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                poi.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
