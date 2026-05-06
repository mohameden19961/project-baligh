// lib/views/alerts/alerts_view.dart
// Placeholder — will be replaced by the full AlertsView in a later step.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_rounded,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.navAlerts,
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
