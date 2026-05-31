// lib/providers/locale_provider.dart
// ─────────────────────────────────────────────────────────────────
// Controller (Provider) responsible for managing the active locale.
// Persists the user's language choice via SharedPreferences so it
// survives app restarts.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  // ── Storage key ──────────────────────────────────────────────────
  static const String _kLocaleKey = 'app_locale';

  // ── Default locale: Arabic ────────────────────────────────────────
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  // ── Constructor: load persisted locale ────────────────────────────
  LocaleProvider() {
    _loadLocale();
  }

  /// Load the saved locale from SharedPreferences.
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_kLocaleKey);
    if (savedCode != null) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }

  /// Change the active locale and persist the choice.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  /// Check whether the current locale is RTL.
  bool get isRtl => _locale.languageCode == 'ar';
}
