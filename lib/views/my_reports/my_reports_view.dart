// lib/views/my_reports/my_reports_view.dart
// Placeholder — will be replaced by the full MyReportsView in a later step.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';

class MyReportsView extends StatelessWidget {
  const MyReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.assignment_outlined,
      title: l10n.myReportsTitle,
      message: l10n.myReportsEmpty,
    );
  }
}
