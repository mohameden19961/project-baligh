// MVC - View
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_view.dart';
import '../settings/settings_view.dart';
import '../emergency/emergency_numbers_view.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.navAccount),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SizedBox(height: 8),
          _ProfileHeader(theme: theme, l10n: l10n),
          const SizedBox(height: 24),
          _StatsCard(l10n: l10n, theme: theme),
          const SizedBox(height: 24),
          _MenuSection(l10n: l10n, theme: theme),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.theme, required this.l10n});
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final username = user?.username ?? 'مستخدم بلّغ';
    final initial = username.isNotEmpty ? username[0] : 'م';
    final joinDate = user?.createdAt;
    final joinDateStr = joinDate != null
        ? '${joinDate.year}/${joinDate.month.toString().padLeft(2, '0')}'
        : 'يناير 2025';

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.accountJoinDate}: $joinDateStr',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.50),
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatefulWidget {
  const _StatsCard({required this.l10n, required this.theme});
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> {
  int? _reportsCount;
  int? _confirmedCount;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  /// Fetches stats specific to the current user from Supabase:
  /// - COUNT(*) FROM reports WHERE user_id = currentUserId
  /// - SUM(confirm_count) FROM reports WHERE user_id = currentUserId
  Future<void> _fetchUserStats() async {
    final userId = context.read<AuthProvider>().currentUserId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final client = Supabase.instance.client;

      // Fetch all user reports and compute both stats in one query
      final response = await client
          .from('reports')
          .select('confirm_count')
          .eq('user_id', userId);

      final rows = response as List<dynamic>;
      final reportsCount = rows.length;
      final confirmedCount = rows.fold<int>(
        0,
        (sum, row) => sum + ((row['confirm_count'] as num?)?.toInt() ?? 0),
      );

      if (mounted) {
        setState(() {
          _reportsCount = reportsCount;
          _confirmedCount = confirmedCount;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[_StatsCard] fetchUserStats error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: widget.theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _loading
          ? const SizedBox(
              height: 72,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    value: '${_reportsCount ?? 0}',
                    label: widget.l10n.accountReportsSubmitted,
                    color: widget.theme.colorScheme.primary,
                  ),
                  VerticalDivider(
                    color: widget.theme.colorScheme.outline.withOpacity(0.15),
                    thickness: 1,
                  ),
                  _StatItem(
                    value: '${_confirmedCount ?? 0}',
                    label: widget.l10n.statusValidated,
                    color: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
    );
  }
}


class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.50),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.l10n, required this.theme});
  final AppLocalizations l10n;
  final ThemeData theme;

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
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.settings_rounded,
            title: l10n.accountSettings,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsView()),
            ),
          ),
          _MenuTile(
            icon: Icons.local_phone_rounded,
            title: l10n.accountEmergencyNumbers,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const EmergencyNumbersView()),
            ),
          ),
          _MenuTile(
            icon: Icons.logout_rounded,
            title: l10n.accountLogout,
            isDestructive: true,
            onTap: () => _showLogoutDialog(context, l10n),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.accountLogout),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius:
          showDivider ? BorderRadius.zero : BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withOpacity(0.70),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.30),
            ),
          ],
        ),
      ),
    );
  }
}
