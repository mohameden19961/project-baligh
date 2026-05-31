// MVC - View
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../controllers/alert_controller.dart';
import '../../controllers/auth_controller.dart';
import '../report_detail/report_detail_view.dart';

class AlertsView extends StatefulWidget {
  const AlertsView({super.key});

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      final auth = context.read<AuthProvider>();
      final uid = auth.currentUserId;
      debugPrint('[AlertsView] didChangeDependencies: userId=$uid');
      if (uid != null) {
        context.read<AlertProvider>().fetchAlerts(userId: uid);
        _fetched = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.alertsTitle),
        actions: [
          Consumer2<AlertProvider, AuthProvider>(
            builder: (_, provider, auth, __) {
              if (provider.unreadCount == 0 || !auth.isAuthenticated) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.done_all_rounded),
                tooltip: l10n.alertMarkAllRead,
                onPressed: () => provider.markAllAsRead(auth.currentUserId!),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AlertProvider, AuthProvider>(
        builder: (context, provider, auth, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 72,
                        color: theme.colorScheme.primary.withOpacity(0.25)),
                    const SizedBox(height: 16),
                    Text(l10n.alertsEmpty,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                        ),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (auth.isAuthenticated) {
                await provider.refresh(auth.currentUserId!);
              }
            },
            color: theme.colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: provider.alerts.length,
              itemBuilder: (context, index) {
                final alert = provider.alerts[index];
                return _AlertTile(
                  alert: alert,
                  l10n: l10n,
                  theme: theme,
                  onTap: () {
                    provider.markAsRead(alert.id);
                    if (alert.reportId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailView(reportId: alert.reportId!),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.alert,
    required this.l10n,
    required this.theme,
    required this.onTap,
  });

  final AppAlert alert;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = alert.isRead
        ? theme.colorScheme.onSurface.withOpacity(0.35)
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: alert.isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_alert_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.alertTileTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: alert.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!alert.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(alert.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoDays(diff.inDays);
  }
}
