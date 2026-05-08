import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('تطبيق بلّغ'),
          _buildSettingTile(
            icon: Icons.language,
            title: 'اللغة',
            subtitle: _getLanguageName(currentLocale.languageCode),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          _buildSettingTile(
            icon: Icons.dark_mode_outlined,
            title: 'الوضع الليلي',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              activeColor: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('التنبيهات والموقع'),
          _buildSettingTile(
            icon: Icons.notifications_active_outlined,
            title: 'تنبيهات الهاتف',
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeColor: AppTheme.primaryGreen,
            ),
          ),
          _buildSettingTile(
            icon: Icons.gps_fixed,
            title: 'دقة الموقع (GPS)',
            subtitle: 'متوازن (موصى به)',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('الحساب'),
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'سياسة الخصوصية',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'عن تطبيق بلّغ',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
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
        title: const Text(
          'اختر اللغة',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: titleColor ?? AppTheme.primaryGreen),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? AppTheme.darkText,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null ? Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo'),
          ) : null,
          trailing: trailing ?? const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
        ),
      ),

    );
  }
}

