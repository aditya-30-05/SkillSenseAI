import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:trainer_app/app/theme.dart';

/// Flip Fade Text rotator specifically designed for the landing/hero area.
/// Cycles through dynamic contextual keywords with a 3D flip and fade transition.
class FlipFadeText extends StatefulWidget {
  final List<String> words;
  final Duration interval;
  final Duration transitionDuration;
  final TextStyle? style;
  final bool showBadge;
  final String? prefix;

  const FlipFadeText({
    super.key,
    required this.words,
    this.interval = const Duration(milliseconds: 2800),
    this.transitionDuration = const Duration(milliseconds: 650),
    this.style,
    this.showBadge = false,
    this.prefix,
  });

  @override
  State<FlipFadeText> createState() => _FlipFadeTextState();
}

class _FlipFadeTextState extends State<FlipFadeText>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animCtrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _animCtrl = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    )..value = 1.0;

    _startTimer();
  }

  void _startTimer() {
    if (widget.words.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (timer) {
      if (!mounted) return;
      _animCtrl.forward(from: 0.0);
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.words.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) return const SizedBox.shrink();

    final currentWord = widget.words[_currentIndex];
    final defaultStyle = widget.style ??
        const TextStyle(
          color: AppColors.teal,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        );

    final content = AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        final progress = _animCtrl.value;
        // Flip in from -90 deg to 0 deg
        final angle = (1.0 - progress) * (math.pi / 2.2);
        final opacity = progress.clamp(0.0, 1.0);

        return Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0018)
            ..rotateX(-angle),
          child: Opacity(
            opacity: opacity,
            child: Text(
              currentWord,
              style: defaultStyle,
              key: ValueKey<int>(_currentIndex),
            ),
          ),
        );
      },
    );

    if (widget.showBadge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            if (widget.prefix != null) ...[
              Text(
                widget.prefix!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
            ],
            content,
          ],
        ),
      );
    }

    if (widget.prefix != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.prefix!,
            style: defaultStyle.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          content,
        ],
      );
    }

    return content;
  }
}
