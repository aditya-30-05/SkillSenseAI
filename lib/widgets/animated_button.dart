import 'package:flutter/material.dart';
import 'package:trainer_app/app/theme.dart';

enum AnimatedButtonVariant {
  primary,
  secondary,
  outline,
  warning,
  critical,
}

/// Ultra-premium animated cyber button with micro-press physics,
/// glowing animated border gradient, and hover shimmer effect.
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final AnimatedButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const AnimatedButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.variant = AnimatedButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 46,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
    this.borderRadius,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    switch (widget.variant) {
      case AnimatedButtonVariant.primary:
        return AppColors.teal;
      case AnimatedButtonVariant.secondary:
        return AppColors.blue;
      case AnimatedButtonVariant.warning:
        return AppColors.warning;
      case AnimatedButtonVariant.critical:
        return AppColors.critical;
      case AnimatedButtonVariant.outline:
        return AppColors.textPrimary;
    }
  }

  Color get _backgroundColor {
    if (widget.variant == AnimatedButtonVariant.outline) {
      return _isHovered
          ? AppColors.surfaceElevated
          : Colors.transparent;
    }
    if (widget.variant == AnimatedButtonVariant.primary) {
      return _isHovered
          ? AppColors.teal
          : AppColors.tealDark.withValues(alpha: 0.95);
    }
    if (widget.variant == AnimatedButtonVariant.critical) {
      return _isHovered ? AppColors.critical : const Color(0xFFDC2626);
    }
    if (widget.variant == AnimatedButtonVariant.warning) {
      return _isHovered
          ? AppColors.warning
          : AppColors.warning.withValues(alpha: 0.85);
    }
    return _isHovered ? AppColors.blueLight : AppColors.blue;
  }

  Color get _textColor {
    if (widget.variant == AnimatedButtonVariant.outline) {
      return _isHovered ? AppColors.teal : AppColors.textPrimary;
    }
    if (widget.variant == AnimatedButtonVariant.primary ||
        widget.variant == AnimatedButtonVariant.warning) {
      return const Color(0xFF080A0F);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final radius = widget.borderRadius ?? BorderRadius.circular(10);

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) {
        if (isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isEnabled) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (isEnabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (isEnabled) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (isEnabled) setState(() => _isPressed = false);
        },
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : (_isHovered ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: radius,
              border: Border.all(
                color: widget.variant == AnimatedButtonVariant.outline
                    ? (_isHovered ? AppColors.teal : AppColors.navyBorder)
                    : (_isHovered
                        ? _primaryColor.withValues(alpha: 0.9)
                        : _primaryColor.withValues(alpha: 0.4)),
                width: 1.2,
              ),
              boxShadow: _isHovered && isEnabled
                  ? [
                      BoxShadow(
                        color: _primaryColor.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                      ),
                    )
                  : widget.child ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 16, color: _textColor),
                            const SizedBox(width: 8),
                          ],
                          if (widget.text != null)
                            Text(
                              widget.text!,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
