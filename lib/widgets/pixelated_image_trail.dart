import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trainer_app/app/theme.dart';

class _TrailParticle {
  final Offset position;
  final double initialOpacity;
  final DateTime createdAt;
  final int sliceIndex;
  final double size;

  _TrailParticle({
    required this.position,
    required this.initialOpacity,
    required this.createdAt,
    required this.sliceIndex,
    required this.size,
  });
}

/// Interactive Pixelated Image Trail Component for the Drone Visual Area.
/// Renders an interactive aerospace drone telemetry canvas that spawns
/// pixelated slicing quads and holographic trail particles on cursor movement.
class PixelatedImageTrail extends StatefulWidget {
  final List<String> images;
  final double height;
  final double imageSize;
  final int slices;
  final Widget? overlayChild;

  const PixelatedImageTrail({
    super.key,
    this.images = const [],
    this.height = 360,
    this.imageSize = 180,
    this.slices = 5,
    this.overlayChild,
  });

  @override
  State<PixelatedImageTrail> createState() => _PixelatedImageTrailState();
}

class _PixelatedImageTrailState extends State<PixelatedImageTrail>
    with SingleTickerProviderStateMixin {
  final List<_TrailParticle> _particles = [];
  late AnimationController _tickerCtrl;
  Offset? _lastPointerPos;
  int _sliceCounter = 0;

  @override
  void initState() {
    super.initState();
    _tickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _tickerCtrl.addListener(_cleanupParticles);
  }

  void _cleanupParticles() {
    if (_particles.isEmpty) return;
    final now = DateTime.now();
    setState(() {
      _particles.removeWhere(
        (p) => now.difference(p.createdAt).inMilliseconds > 1400,
      );
    });
  }

  @override
  void dispose() {
    _tickerCtrl.removeListener(_cleanupParticles);
    _tickerCtrl.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerHoverEvent event) {
    final pos = event.localPosition;
    if (_lastPointerPos != null) {
      final dist = (pos - _lastPointerPos!).distance;
      if (dist < 18) return; // Spawn threshold
    }
    _lastPointerPos = pos;
    _sliceCounter = (_sliceCounter + 1) % widget.slices;

    setState(() {
      _particles.add(
        _TrailParticle(
          position: pos,
          initialOpacity: 0.85,
          createdAt: DateTime.now(),
          sliceIndex: _sliceCounter,
          size: 42.0 + (_sliceCounter * 6.0),
        ),
      );
      if (_particles.length > 24) {
        _particles.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.teal.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: MouseRegion(
        onHover: _onPointerHover,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Drone Blueprint HUD
            CustomPaint(
              painter: _DroneBlueprintPainter(),
            ),

            // Interactive Trail Particles
            CustomPaint(
              painter: _PixelatedTrailPainter(particles: _particles),
            ),

            // Top Status Overlay (Tech telemetry)
            Positioned(
              top: 14,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.navyLight.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flight_takeoff, color: AppColors.teal, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'AEROGUARD QUAD-X TELEMETRY HUD',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.safe.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPTICAL SENSORS ACTIVE',
                      style: TextStyle(
                        color: AppColors.safe,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Custom child if provided
            if (widget.overlayChild != null) widget.overlayChild!,
          ],
        ),
      ),
    );
  }
}

class _DroneBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.navyBorder.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Concentric Radar Rings
    final radarPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(Offset(cx, cy), 50, radarPaint);
    canvas.drawCircle(Offset(cx, cy), 110, radarPaint);
    canvas.drawCircle(Offset(cx, cy), 170, radarPaint);

    // Crosshairs
    final crossPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx - 180, cy), Offset(cx + 180, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - 130), Offset(cx, cy + 130), crossPaint);

    // Drone Silhouette / Structure
    final dronePaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Central fuselage
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 54, height: 42),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, dronePaint);

    // Center Camera Sensor lens
    final lensPaint = Paint()
      ..color = AppColors.blue.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 10, lensPaint);

    // 4 Quadcopter Arms
    final armPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.6)
      ..strokeWidth = 3;

    // Arm 1 (Top-Left)
    canvas.drawLine(Offset(cx - 20, cy - 15), Offset(cx - 90, cy - 65), armPaint);
    // Arm 2 (Top-Right)
    canvas.drawLine(Offset(cx + 20, cy - 15), Offset(cx + 90, cy - 65), armPaint);
    // Arm 3 (Bottom-Left)
    canvas.drawLine(Offset(cx - 20, cy + 15), Offset(cx - 90, cy + 65), armPaint);
    // Arm 4 (Bottom-Right)
    canvas.drawLine(Offset(cx + 20, cy + 15), Offset(cx + 90, cy + 65), armPaint);

    // 4 Motor Rotors
    final rotorPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawCircle(Offset(cx - 90, cy - 65), 26, rotorPaint);
    canvas.drawCircle(Offset(cx + 90, cy - 65), 26, rotorPaint);
    canvas.drawCircle(Offset(cx - 90, cy + 65), 26, rotorPaint);
    canvas.drawCircle(Offset(cx + 90, cy + 65), 26, rotorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelatedTrailPainter extends CustomPainter {
  final List<_TrailParticle> particles;

  _PixelatedTrailPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    for (final p in particles) {
      final ageMs = now.difference(p.createdAt).inMilliseconds;
      final lifeRatio = (1.0 - (ageMs / 1400)).clamp(0.0, 1.0);
      if (lifeRatio <= 0) continue;

      final opacity = p.initialOpacity * lifeRatio;
      final half = p.size / 2;

      // Outer cyber box
      final boxPaint = Paint()
        ..color = AppColors.teal.withValues(alpha: opacity * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      final rect = Rect.fromCenter(center: p.position, width: p.size, height: p.size);
      canvas.drawRect(rect, boxPaint);

      // Inner pixelated sliced tiles (5 slices)
      final sliceCount = 4;
      final sliceW = p.size / sliceCount;
      final fillPaint = Paint()
        ..color = AppColors.teal.withValues(alpha: opacity * 0.16)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < sliceCount; i++) {
        if ((i + p.sliceIndex) % 2 == 0) {
          final sRect = Rect.fromLTWH(
            p.position.dx - half + (i * sliceW),
            p.position.dy - half,
            sliceW - 2,
            p.size,
          );
          canvas.drawRect(sRect, fillPaint);
        }
      }

      // Small tech coordinate crosshair
      final crossPaint = Paint()
        ..color = AppColors.teal.withValues(alpha: opacity * 0.75)
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(p.position.dx - 4, p.position.dy),
        Offset(p.position.dx + 4, p.position.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(p.position.dx, p.position.dy - 4),
        Offset(p.position.dx, p.position.dy + 4),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelatedTrailPainter oldDelegate) => true;
}
