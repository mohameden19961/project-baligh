import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baligh/core/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const BalighApp(),
    ),
  );
}

class BalighApp extends ConsumerWidget {
  const BalighApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Baligh',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.darkTheme, // We primarily use Dark Theme as requested
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
