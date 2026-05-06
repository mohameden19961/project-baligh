// lib/views/account/account_view.dart
// Placeholder — will be replaced by the full AccountView in a later step.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.navAccount,
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
