// lib/providers/navigation_provider.dart
// ─────────────────────────────────────────────────────────────────
// Controller layer — owns the single selected tab index for the
// entire app shell. Kept intentionally thin: no persistence needed
// since tab state should reset to Home on every cold start.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

// ════════════════════════════════════════════════════════════════
// ENUM: AppTab
// Named tabs make the rest of the codebase readable:
//   provider.currentTab == AppTab.home   ← clear intent
//   provider.currentTab == 0             ← magic number, avoid this
// ════════════════════════════════════════════════════════════════
enum AppTab {
  home,       // index 0 — الرئيسية
  myReports,  // index 1 — بلاغاتي
  alerts,     // index 2 — تنبيهات
  account,    // index 3 — حسابي
}

// ════════════════════════════════════════════════════════════════
// CLASS: NavigationProvider
// ════════════════════════════════════════════════════════════════
class NavigationProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.home;

  // ── Getters ──────────────────────────────────────────────────────
  AppTab get currentTab => _currentTab;

  /// Integer index consumed directly by BottomNavigationBar.
  int get currentIndex => _currentTab.index;

  // ── Navigation ───────────────────────────────────────────────────

  /// Switch to a tab by its [AppTab] value.
  void navigateTo(AppTab tab) {
    if (_currentTab == tab) return; // no-op avoids redundant rebuilds
    _currentTab = tab;
    notifyListeners();
  }

  /// Switch to a tab by its raw [index] (used by BottomNavigationBar.onTap).
  void navigateToIndex(int index) {
    final tab = AppTab.values[index];
    navigateTo(tab);
  }

  // ── Convenience helpers (used by FAB deep-links) ─────────────────
  bool get isHome      => _currentTab == AppTab.home;
  bool get isMyReports => _currentTab == AppTab.myReports;
  bool get isAlerts    => _currentTab == AppTab.alerts;
  bool get isAccount   => _currentTab == AppTab.account;
}
