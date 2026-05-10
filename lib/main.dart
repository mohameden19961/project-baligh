// lib/main.dart
// ─────────────────────────────────────────────────────────────
// Entry point for the Baligh (بلّغ) application.
// Architecture : MVC  |  State : Provider  |  i18n : AppLocalizations
// ─────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/report_provider.dart';
import 'views/main_layout.dart';


// ── Generated localization class (manual path — no flutter_gen phantom) ──
import 'l10n/app_localizations.dart';

// ── Providers (Controllers) ───────────────────────────────────────
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
// Future providers are registered here as the project grows:
// import 'providers/report_provider.dart';
// import 'providers/map_provider.dart';

// ── Views (Screens) ───────────────────────────────────────────────
// import 'views/home/home_view.dart'; // ← uncomment when created
// import 'views/splash/splash_view.dart';

// ─────────────────────────────────────────────────────────────────
void main() async {
  // Ensure Flutter engine is initialized before any platform calls.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode for a consistent UX.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make the status bar transparent so our green AppBar bleeds through.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── FMTC tile-cache initialization (native platforms only) ──────
  // FMTCObjectBoxBackend uses FFI and is not available on web.
  // On web, TileLayers fall back to NetworkTileProvider directly.
  if (!kIsWeb) {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore('osm_cache').manage.create();
  }
  // ───────────────────────────────────────────────────────────────

  runApp(
    // ── Register all Providers at the root ───────────────────────
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const BalighApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
/// Root widget of the Baligh application.
/// Listens to [LocaleProvider] and [ThemeProvider] to rebuild
/// [MaterialApp] whenever the user changes language or theme.
// ─────────────────────────────────────────────────────────────────
class BalighApp extends StatelessWidget {
  const BalighApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch providers — any change triggers a full MaterialApp rebuild.
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      // ── App identity ────────────────────────────────────────────
      title: 'Baligh',
      debugShowCheckedModeBanner: false,

      // ── Theming ─────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // ── Internationalization ─────────────────────────────────────
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Resolve RTL/LTR automatically from the active locale.
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) {
            return supported;
          }
        }
        // Default to Arabic if no match.
        return const Locale('ar');
      },

      // ── Navigation ───────────────────────────────────────────────
      home: const MainLayout(),

      // Named routes will be added here as screens are built:
      // routes: {
      //   '/':          (_) => const SplashView(),
      //   '/home':      (_) => const HomeView(),
      //   '/report':    (_) => const ReportView(),
      //   '/map':       (_) => const MapView(),
      //   '/myReports': (_) => const MyReportsView(),
      //   '/settings':  (_) => const SettingsView(),
      // },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
/// Temporary placeholder displayed until the real HomeView is built.
/// It demonstrates that localization and theming are wired correctly.
// ─────────────────────────────────────────────────────────────────
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appTagline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Language switcher for quick testing during development.
            _LanguageSwitcher(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
/// Dev-only language switcher widget — will be replaced by
/// the full SettingsView once it is built.
// ─────────────────────────────────────────────────────────────────
class _LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Column(
      children: [
        Text(
          l10n.language,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LangButton(
              label: l10n.arabic,
              isSelected: isArabic,
              onTap: () => localeProvider.setLocale(const Locale('ar')),
            ),
            const SizedBox(width: 12),
            _LangButton(
              label: l10n.french,
              isSelected: !isArabic,
              onTap: () => localeProvider.setLocale(const Locale('fr')),
            ),
          ],
        ),
      ],
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
/// Centralized theme definitions for the Baligh design system.
///
/// Palette:
///   Primary Green  → #2E7D32
///   Accent Yellow  → #FDD835
///   Background     → #FFFFFF (light) / #121212 (dark)
/// ─────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Brand Colors ────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentYellow = Color(0xFFFDD835);
  static const Color darkYellow = Color(0xFFF9A825);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF121212);
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  // ── Light Theme ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: accentYellow,
        surface: white,
        error: const Color(0xFFB00020),
      ),

      // ── AppBar ───────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // ── Scaffold ─────────────────────────────────────────────────
      scaffoldBackgroundColor: surfaceGrey,

      // ── Bottom Navigation ─────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── ElevatedButton ────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── InputDecoration ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
        labelStyle: const TextStyle(color: Color(0xFF757575)),
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
      ),

      // ── Card ──────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceGrey,
        selectedColor: lightGreen.withOpacity(0.2),
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ── FloatingActionButton ──────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 4,
      ),

      // ── Divider ───────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
      ),

      // ── Typography ────────────────────────────────────────────────
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: nearBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: nearBlack,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: nearBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: nearBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: nearBlack,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF424242)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF616161)),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: nearBlack,
        ),
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightGreen,
        brightness: Brightness.dark,
        primary: lightGreen,
        secondary: accentYellow,
        surface: const Color(0xFF1E1E1E),
        error: const Color(0xFFCF6679),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B5E20),
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: nearBlack,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: lightGreen,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGreen, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightGreen,
        foregroundColor: white,
      ),
    );
  }
}
