// MVC - View
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../controllers/locale_provider.dart';
import '../../controllers/theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SizedBox(height: 8),
          _SectionCard(
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.palette_rounded,
                title: l10n.settingsTheme,
                trailing: Consumer<ThemeProvider>(
                  builder: (_, tp, __) {
                    return DropdownButton<ThemeMode>(
                      value: tp.themeMode,
                      onChanged: (mode) {
                        if (mode != null) tp.setThemeMode(mode);
                      },
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: ThemeMode.light, child: Text("Clair")),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text("Sombre")),
                        DropdownMenuItem(value: ThemeMode.system, child: Text("Automatique")),
                      ],
                      isDense: true,
                    );
                  },
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.language_rounded,
                title: l10n.settingsLanguage,
                trailing: Consumer<LocaleProvider>(
                  builder: (_, lp, __) => SegmentedButton<Locale>(
                    segments: [
                      ButtonSegment(
                        value: const Locale('ar'),
                        label: Text(l10n.arabic,
                            style: const TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: const Locale('fr'),
                        label: Text(l10n.french,
                            style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {lp.locale},
                    onSelectionChanged: (locales) =>
                        lp.setLocale(locales.first),
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            theme: theme,
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: l10n.settingsAbout,
                onTap: () => _showAboutDialog(context, l10n),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingsPrivacy,
                onTap: () => _showPrivacySheet(context, l10n),
              ),
              _SettingsTile(
                icon: Icons.mail_outline_rounded,
                title: l10n.settingsContact,
                onTap: () => _showContactSheet(context, l10n),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${l10n.settingsVersion} 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.35),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isAr = l10n.localeName == 'العربية';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🇲🇷', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Text('بلّغ (Baligh)'),
          ],
        ),
        content: Text(
          isAr
              ? 'الإصدار: 1.0.0\n\n'
                  'تطبيق مجتمعي للإبلاغ عن المشكلات في المدن الموريتانية.\n'
                  'يساعد المواطنين على التواصل مع البلديات لحل المشكلات بسرعة.\n\n'
                  'تم التطوير في المعهد الوطني للإحصاء والاقتصاد التطبيقي (SupNum)\n'
                  'نواكشوط، موريتانيا\n'
                  'S4 DWM 2024\n\n'
                  'المطور: أحمد ولد بده\n'
                  'GitHub: github.com/abdylbdt'
              : 'Version : 1.0.0\n\n'
                  'Application communautaire pour signaler les problèmes dans les villes mauritaniennes.\n'
                  'Aide les citoyens à communiquer avec les municipalités pour résoudre les problèmes rapidement.\n\n'
                  'Développé à SupNum (Institut National de Statistique et d\'Économie Appliquée)\n'
                  'Nouakchott, Mauritanie\n'
                  'S4 DWM 2024\n\n'
                  'Développeur : Ahmed o/ Badah\n'
                  'GitHub : github.com/abdylbdt',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );
  }

  void _showPrivacySheet(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isAr = l10n.localeName == 'العربية';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(l10n.settingsPrivacy,
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text(
                  isAr
                      ? 'تطبيق بلّغ يحترم خصوصيتك. نحن نجمع فقط البيانات الضرورية لتشغيل التطبيق:\n\n'
                          '• الموقع الجغرافي: يستخدم لتحديد موقع البلاغ على الخريطة\n'
                          '• الصور: يتم تخزينها بشكل آمن في السحابة\n'
                          '• المعلومات الشخصية: تقتصر على اسم المستخدم والبريد الإلكتروني\n\n'
                          'لا تتم مشاركة بياناتك مع أطراف ثالثة. يمكنك طلب حذف بياناتك في أي وقت بالتواصل معنا.'
                      : 'Baligh respecte votre vie privée. Nous collectons uniquement les données nécessaires au fonctionnement de l\'application :\n\n'
                          '• Localisation : utilisée pour situer le signalement sur la carte\n'
                          '• Photos : stockées de manière sécurisée dans le cloud\n'
                          '• Informations personnelles : limitées au nom d\'utilisateur et à l\'email\n\n'
                          'Vos données ne sont pas partagées avec des tiers. Vous pouvez demander la suppression de vos données à tout moment en nous contactant.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.confirmButton),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  void _showContactSheet(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.settingsContact,
                  style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text('24068@supnum.mr',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'العربية: يمكنك مراسلتنا على هذا البريد الإلكتروني لأي استفسار أو اقتراح.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55)),
              ),
              const SizedBox(height: 4),
              Text(
                'Français : Vous pouvez nous écrire à cette adresse pour toute question ou suggestion.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await launchUrl(
                        Uri.parse('https://mail.google.com/mail/?view=cm&to=24068@supnum.mr'),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('إرسال بريد إلكتروني'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.confirmButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.theme, required this.children});
  final ThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 22,
                    color: theme.colorScheme.onSurface.withOpacity(0.70)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (trailing != null)
                  Flexible(
                    child: trailing!,
                  ),
                if (onTap != null && trailing == null)
                  Padding(
                    padding: EdgeInsets.only(right: isLtr ? 0 : 4, left: isLtr ? 4 : 0),
                    child: Icon(
                      isLtr
                          ? Icons.chevron_right_rounded
                          : Icons.chevron_left_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.30),
                    ),
                  ),
              ],
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.08),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
