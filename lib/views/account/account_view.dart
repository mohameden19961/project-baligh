// lib/views/account/account_view.dart
// Placeholder — will be replaced by the full AccountView in a later step.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.person_outline,
      title: l10n.navAccount,
      message: l10n.homeSubtitle,
    );
  }
}
