import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

class NotchNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NotchNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating Notch / Dynamic Island Navbar.
/// Replaces the visual layer of the navigation with a floating,
/// frosted-glass aerospace notch with an animated active pill indicator
/// and live drone telemetry badge.
class NotchNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<NotchNavItem> items;
  final String? statusText;
  final Widget? trailing;

  const NotchNavbar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
    this.statusText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF090E17).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.teal.withValues(alpha: 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left Notch Brand & Live Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.navyBorder.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulseDot(color: AppColors.safe, size: 6),
                    const SizedBox(width: 8),
                    Text(
                      statusText ?? 'AEROGUARD • DRONE-01',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 24,
                width: 1,
                color: AppColors.navyBorder.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              // Navigation Items Row
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isSelected = index == currentIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _NotchItemButton(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => onItemSelected(index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.navyBorder.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotchItemButton extends StatefulWidget {
  final NotchNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotchItemButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NotchItemButton> createState() => _NotchItemButtonState();
}

class _NotchItemButtonState extends State<_NotchItemButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBg = AppColors.teal.withValues(alpha: 0.16);
    final hoverBg = AppColors.surfaceElevated.withValues(alpha: 0.5);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.item.label,
          preferBelow: true,
          decoration: BoxDecoration(
            color: const Color(0xFF141C2B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.navyBorder),
          ),
          textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? activeBg
                  : (_isHovered ? hoverBg : Colors.transparent),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.teal.withValues(alpha: 0.5)
                    : (_isHovered
                        ? AppColors.navyBorder
                        : Colors.transparent),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  size: 16,
                  color: widget.isSelected
                      ? AppColors.teal
                      : (_isHovered ? AppColors.textPrimary : AppColors.textSecondary),
                ),
                const SizedBox(width: 7),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isSelected
                        ? AppColors.teal
                        : (_isHovered ? AppColors.textPrimary : AppColors.textSecondary),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
