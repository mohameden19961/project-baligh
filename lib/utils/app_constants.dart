// lib/utils/app_constants.dart
// ─────────────────────────────────────────────────────────────────
// Project-wide compile-time constants. Add new entries here only
// when a literal is referenced by more than one file.
// ─────────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  /// FMTC store name used by every TileLayer + the boot-time
  /// `FMTCStore(...).manage.create()` call. Must stay identical
  /// across all call sites — a mismatch silently creates a second
  /// empty store.
  static const String osmCacheStoreName = 'osm_cache';
}
