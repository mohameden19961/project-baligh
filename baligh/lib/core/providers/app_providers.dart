import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences prefs;
  LocaleNotifier(this.prefs) : super(_loadLocale(prefs));

  static Locale _loadLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString('language_code') ?? 'ar';
    return Locale(languageCode);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await prefs.setString('language_code', languageCode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences prefs;
  ThemeNotifier(this.prefs) : super(_loadTheme(prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final theme = prefs.getString('theme_mode') ?? 'dark';
    return theme == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setString('theme_mode', state == ThemeMode.light ? 'light' : 'dark');
  }
}
