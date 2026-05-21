// lib/utils/report_category_meta.dart
// ─────────────────────────────────────────────────────────────────
// Single source of truth for every ReportCategory's visual metadata:
//   • icon  (Material rounded icon)
//   • color (brand-aligned hex)
//   • label (localized via AppLocalizations)
//
// Consumed by:
//   • providers/map_provider.dart      → marker colour + icon
//   • views/map/map_view.dart          → filter chip row
//   • widgets/report_card.dart         → category badge on each card
//   • views/add_report/add_report_view → wizard category grid + review row
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/report_model.dart';

class ReportCategoryMeta {
  const ReportCategoryMeta({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  /// Icon + colour for a given category. Pure presentation; no l10n needed.
  static ReportCategoryMeta of(ReportCategory cat) => switch (cat) {
        ReportCategory.roads    => const ReportCategoryMeta(icon: Icons.construction_rounded,      color: Color(0xFFEF6C00)),
        ReportCategory.lighting => const ReportCategoryMeta(icon: Icons.lightbulb_outline_rounded, color: Color(0xFFF9A825)),
        ReportCategory.waste    => const ReportCategoryMeta(icon: Icons.delete_outline_rounded,    color: Color(0xFF6D4C41)),
        ReportCategory.water    => const ReportCategoryMeta(icon: Icons.water_drop_outlined,       color: Color(0xFF0277BD)),
        ReportCategory.parks    => const ReportCategoryMeta(icon: Icons.park_outlined,             color: Color(0xFF388E3C)),
        ReportCategory.other    => const ReportCategoryMeta(icon: Icons.report_problem_outlined,   color: Color(0xFF7B1FA2)),
      };

  /// Localized human-readable label for a category.
  static String label(ReportCategory cat, AppLocalizations l10n) =>
      switch (cat) {
        ReportCategory.roads    => l10n.categoryRoads,
        ReportCategory.lighting => l10n.categoryLighting,
        ReportCategory.waste    => l10n.categoryWaste,
        ReportCategory.water    => l10n.categoryWater,
        ReportCategory.parks    => l10n.categoryParks,
        ReportCategory.other    => l10n.categoryOther,
      };
}
