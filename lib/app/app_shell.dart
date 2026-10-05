import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/providers/app_provider.dart';
import 'package:trainer_app/widgets/common_widgets.dart';
import 'package:trainer_app/features/dashboard/dashboard_screen.dart';
import 'package:trainer_app/features/trainees/trainees_screen.dart';
import 'package:trainer_app/features/live_monitor/live_monitor_screen.dart';
import 'package:trainer_app/features/hazard_map/hazard_map_screen.dart';
import 'package:trainer_app/features/sessions/sessions_screen.dart';
import 'package:trainer_app/features/performance/performance_screen.dart';
import 'package:trainer_app/features/ai_coach/ai_coach_screen.dart';
import 'package:trainer_app/features/reports/reports_screen.dart';
import 'package:trainer_app/features/settings/settings_screen.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
  _NavItem(icon: Icons.school_outlined, activeIcon: Icons.school, label: 'Trainees'),
  _NavItem(icon: Icons.videocam_outlined, activeIcon: Icons.videocam, label: 'Live Monitor'),
  _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Hazard Map'),
  _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Sessions'),
  _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Performance'),
  _NavItem(icon: Icons.smart_toy_outlined, activeIcon: Icons.smart_toy, label: 'AI Coach'),
  _NavItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Reports'),
  _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
];

final _screens = [
  const DashboardScreen(),
  const TraineesScreen(),
  const LiveMonitorScreen(),
  const HazardMapScreen(),
  const SessionsScreen(),
  const PerformanceScreen(),
  const AiCoachScreen(),
  const ReportsScreen(),
  const SettingsScreen(),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 640 && width < 1024;
    final isDemoMode = ref.watch(demoModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (isDemoMode) const DemoModeBanner(),
          Expanded(
            child: isDesktop
                ? _DesktopLayout(navIndex: navIndex)
                : isTablet
                    ? _TabletLayout(navIndex: navIndex)
                    : _MobileLayout(navIndex: navIndex),
          ),
        ],
      ),
    );
  }
}

// ── Screen Transition Switcher ────────────────────────────────────────────────

Widget _buildScreenTransition(int navIndex) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.015, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    child: KeyedSubtree(
      key: ValueKey<int>(navIndex),
      child: _screens[navIndex],
    ),
  );
}

// ── Desktop Layout ────────────────────────────────────────────────────────────

class _DesktopLayout extends ConsumerWidget {
  final int navIndex;
  const _DesktopLayout({required this.navIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _Sidebar(navIndex: navIndex),
        Expanded(child: _buildScreenTransition(navIndex)),
      ],
    );
  }
}

// ── Tablet Layout ─────────────────────────────────────────────────────────────

class _TabletLayout extends ConsumerWidget {
  final int navIndex;
  const _TabletLayout({required this.navIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _RailNav(navIndex: navIndex),
        Expanded(child: _buildScreenTransition(navIndex)),
      ],
    );
  }
}

// ── Mobile Layout ─────────────────────────────────────────────────────────────

class _MobileLayout extends ConsumerWidget {
  final int navIndex;
  const _MobileLayout({required this.navIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomItems = _navItems.take(5).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildScreenTransition(navIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.6), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navIndex < 5 ? navIndex : 0,
          onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedItemColor: AppColors.teal,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: bottomItems
              .asMap()
              .entries
              .map((e) => BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Icon(e.value.icon, size: 20),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Icon(e.value.activeIcon, size: 20),
                    ),
                    label: e.value.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends ConsumerWidget {
  final int navIndex;
  const _Sidebar({required this.navIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.7), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.teal, AppColors.blue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.radar, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'SkillSense',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: AppColors.teal,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'AI Training Platform',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.navyBorder.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          // Nav items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'MAIN MENU',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final active = navIndex == i;
                final item = _navItems[i];
                return _SidebarItem(
                  icon: active ? item.activeIcon : item.icon,
                  label: item.label,
                  isActive: active,
                  onTap: () => ref.read(navIndexProvider.notifier).state = i,
                );
              },
            ),
          ),
          Divider(height: 1, color: AppColors.navyBorder.withValues(alpha: 0.6)),
          // Trainer Profile Footer
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.navyLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'DT',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Trainer',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            PulseDot(color: AppColors.safe, size: 6),
                            SizedBox(width: 5),
                            Text(
                              'Online',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? AppColors.teal.withValues(alpha: 0.12)
                : (_hovered ? AppColors.surfaceElevated.withValues(alpha: 0.5) : Colors.transparent),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: active
                  ? AppColors.teal.withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: active
                    ? AppColors.teal
                    : (_hovered ? AppColors.textPrimary : AppColors.textSecondary),
              ),
              const SizedBox(width: 11),
              Text(
                widget.label,
                style: TextStyle(
                  color: active
                      ? AppColors.teal
                      : (_hovered ? AppColors.textPrimary : AppColors.textSecondary),
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
              if (active) ...[
                const Spacer(),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Rail Nav (Tablet) ─────────────────────────────────────────────────────────

class _RailNav extends ConsumerWidget {
  final int navIndex;
  const _RailNav({required this.navIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.6), width: 1),
        ),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: navIndex,
        onDestinationSelected: (i) => ref.read(navIndexProvider.notifier).state = i,
        selectedIconTheme: const IconThemeData(color: AppColors.teal, size: 22),
        unselectedIconTheme: const IconThemeData(color: AppColors.textMuted, size: 20),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.teal,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
        ),
        labelType: NavigationRailLabelType.all,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.teal, AppColors.blue]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.radar, color: Colors.white, size: 18),
          ),
        ),
        destinations: _navItems
            .map((item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: Text(item.label),
                ))
            .toList(),
      ),
    );
  }
}
