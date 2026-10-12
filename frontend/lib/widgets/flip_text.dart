import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Character/Word Flip Animation Component.
/// Applies a perspective flip reveal character-by-character on mount
/// and interactive re-flip on hover.
class FlipText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration charDelay;
  final TextAlign textAlign;
  final bool animateOnMount;
  final bool animateOnHover;

  const FlipText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 650),
    this.charDelay = const Duration(milliseconds: 30),
    this.textAlign = TextAlign.start,
    this.animateOnMount = true,
    this.animateOnHover = true,
  });

  @override
  State<FlipText> createState() => _FlipTextState();
}

class _FlipTextState extends State<FlipText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.animateOnMount) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerHoverFlip() {
    if (widget.animateOnHover && !_controller.isAnimating) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.text.split('');
    final totalChars = characters.length;
    if (totalChars == 0) return const SizedBox.shrink();

    final defaultStyle = widget.style ??
        Theme.of(context).textTheme.headlineMedium ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

    return MouseRegion(
      onEnter: (_) => _triggerHoverFlip(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Wrap(
            alignment: widget.textAlign == TextAlign.center
                ? WrapAlignment.center
                : WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(totalChars, (index) {
              final char = characters[index];
              if (char == ' ') {
                return Text(' ', style: defaultStyle);
              }

              // Compute staggered animation interval for this character
              final start = (index / totalChars) * 0.55;
              final end = (start + 0.45).clamp(0.0, 1.0);
              final curved = CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeOutBack),
              );

              final flipValue = curved.value; // 0.0 -> 1.0
              final angle = (1.0 - flipValue) * (math.pi / 2); // 90 deg -> 0 deg

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // 3D Perspective
                  ..rotateX(angle),
                child: Opacity(
                  opacity: flipValue.clamp(0.0, 1.0),
                  child: Text(char, style: defaultStyle),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
