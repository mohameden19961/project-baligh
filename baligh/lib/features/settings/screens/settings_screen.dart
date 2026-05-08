import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('APPLICATION'),
          _buildSettingTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _getLanguageName(currentLocale.languageCode),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          _buildSettingTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('ALERTS & GPS'),
          _buildSettingTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildSettingTile(
            icon: Icons.gps_fixed,
            title: 'GPS Accuracy',
            subtitle: 'Balanced (Recommended)',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('ACCOUNT'),
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About Baligh',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.logout,
            title: 'Logout',
            titleColor: Colors.red,
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'fr': return 'Français';
      case 'en': return 'English';
      default: return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        backgroundColor: const Color(0xFF1E1E1E),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangOption(context, ref, 'ar', 'العربية'),
            _buildLangOption(context, ref, 'fr', 'Français'),
            _buildLangOption(context, ref, 'en', 'English'),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(BuildContext context, WidgetRef ref, String code, String name) {
    return ListTile(
      title: Text(name),
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(code);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: titleColor ?? Colors.white70),
      title: Text(title, style: TextStyle(color: titleColor ?? Colors.white)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }
}
