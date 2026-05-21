// lib/views/alerts/alerts_view.dart
// Placeholder — will be replaced by the full AlertsView in a later step.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.notifications_none_outlined,
      title: l10n.navAlerts,
      message: l10n.homeNoReports,
    );
  }
}
