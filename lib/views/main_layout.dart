// lib/views/main_layout.dart
// ─────────────────────────────────────────────────────────────────
// App shell: owns the persistent Scaffold that wraps every tab.
// The BottomNavigationBar has a notched center slot for the FAB.
// Tab switching is handled by NavigationProvider (no setState).
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/navigation_provider.dart';

// ── Tab views ─────────────────────────────────────────────────────
import 'home/home_view.dart';
import 'my_reports/my_reports_view.dart';
import 'alerts/alerts_view.dart';
import 'account/account_view.dart';
import 'add_report/add_report_view.dart';

// ════════════════════════════════════════════════════════════════
// MainLayout
// ════════════════════════════════════════════════════════════════
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  // ── FAB animation controller ──────────────────────────────────────
  // The FAB pulses once on first build to draw attention.
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  // ── Tab body — IndexedStack keeps all views alive (no re-renders) ─
  static const List<Widget> _tabBodies = [
    HomeView(),
    MyReportsView(),
    AlertsView(),
    AccountView(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    // Slight delay so the entrance feels intentional, not rushed.
    Future.delayed(
      const Duration(milliseconds: 300),
      _fabController.forward,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // NavigationProvider is consumed only via Selector — the Scaffold shell
    // (FAB + BottomAppBar + its notch clipper) never rebuilds from provider
    // notifications. Only the two widgets that actually need currentIndex do.
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      // ── Tab body ─────────────────────────────────────────────────
      body: Selector<NavigationProvider, int>(
        selector: (_, nav) => nav.currentIndex,
        builder: (_, index, __) => IndexedStack(
          index: index,
          children: _tabBodies,
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: ScaleTransition(
          scale: _fabScale,
          child: _BalighFab(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddReportView()),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Navigation Bar ─────────────────────────────────────
      bottomNavigationBar: Selector<NavigationProvider, int>(
        selector: (_, nav) => nav.currentIndex,
        builder: (_, index, __) => _BalighBottomNav(
          currentIndex: index,
          onTap: (i) {
            HapticFeedback.selectionClick();
            context.read<NavigationProvider>().navigateToIndex(i);
          },
          l10n: l10n,
          theme: theme,
          isRtl: isRtl,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _BalighFab  — The prominent center "Add Report" button.
// Extracted as its own widget so it can be tested/replaced easily.
// ════════════════════════════════════════════════════════════════
class _BalighFab extends StatefulWidget {
  const _BalighFab({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BalighFab> createState() => _BalighFabState();
}

class _BalighFabState extends State<_BalighFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _pressScale = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _pressController.reverse();
  void _onTapUp(_) {
    _pressController.forward();
    widget.onTap();
  }
  void _onTapCancel() => _pressController.forward();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const accentYellow = Color(0xFFFDD835);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Gradient: green core → slightly lighter green edge.
            gradient: RadialGradient(
              colors: [
                primary.withOpacity(0.92),
                primary,
              ],
              center: Alignment.topLeft,
              radius: 1.4,
            ),
            boxShadow: [
              // Deep green shadow for depth.
              BoxShadow(
                color: primary.withOpacity(0.45),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              // Subtle inner highlight.
              BoxShadow(
                color: Colors.white.withOpacity(0.12),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Yellow accent ring (subtle, not overwhelming).
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentYellow.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
              ),
              // Plus icon.
              const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _BalighBottomNav  — Custom bottom bar with notch + styled items.
// ════════════════════════════════════════════════════════════════
class _BalighBottomNav extends StatelessWidget {
  const _BalighBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.l10n,
    required this.theme,
    required this.isRtl,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    // BottomAppBar gives us the notch cutout for the FAB.
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      // Audit Step 3: tightened from 8.0 → 6.0 for a snugger FAB fit.
      notchMargin: 6.0,
      color: theme.colorScheme.surface,
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.15),
      // Audit Step 3: clip prevents ink/shadow from bleeding outside the notch.
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left side: Home + MyReports (indices 0 and 1).
            _NavItem(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: l10n.navHome,
              onTap: onTap,
              theme: theme,
            ),
            _NavItem(
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment_rounded,
              label: l10n.navMyReports,
              onTap: onTap,
              theme: theme,
            ),

            // Center gap — the FAB sits here via centerDocked location.
            const SizedBox(width: 56),

            // Right side: Alerts + Account (indices 2 and 3).
            _NavItem(
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications_rounded,
              label: l10n.navAlerts,
              onTap: onTap,
              theme: theme,
              // Badge — swap `false` for a real unread-count check later.
              showBadge: false,
            ),
            _NavItem(
              index: 3,
              currentIndex: currentIndex,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: l10n.navAccount,
              onTap: onTap,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _NavItem  — A single animated bottom-nav tab item.
// ════════════════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    required this.theme,
    this.showBadge = false,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;
  final ThemeData theme;
  final bool showBadge;

  bool get _isSelected => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.45);
    const accentYellow = Color(0xFFFDD835);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon with animated pill background ──────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isSelected
                      ? primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: Icon(
                        _isSelected ? activeIcon : icon,
                        key: ValueKey(_isSelected),
                        size: 24,
                        color: _isSelected ? primary : unselectedColor,
                      ),
                    ),
                    // Notification badge.
                    if (showBadge)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: accentYellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              // ── Label ────────────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      _isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: _isSelected ? primary : unselectedColor,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
