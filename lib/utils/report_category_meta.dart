import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/models/report_model.dart';

class ReportCategoryMeta {
  const ReportCategoryMeta({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  static ReportCategoryMeta of(ReportCategory cat) => switch (cat) {
        ReportCategory.electricity    => const ReportCategoryMeta(icon: Icons.flash_on_rounded,         color: Color(0xFFF9A825)),
        ReportCategory.road           => const ReportCategoryMeta(icon: Icons.construction_rounded,     color: Color(0xFFEF6C00)),
        ReportCategory.flood          => const ReportCategoryMeta(icon: Icons.water_rounded,            color: Color(0xFF0277BD)),
        ReportCategory.security       => const ReportCategoryMeta(icon: Icons.shield_rounded,           color: Color(0xFF37474F)),
        ReportCategory.water          => const ReportCategoryMeta(icon: Icons.water_drop_outlined,      color: Color(0xFF1565C0)),
        ReportCategory.health         => const ReportCategoryMeta(icon: Icons.local_hospital_rounded,   color: Color(0xFFC62828)),
        ReportCategory.internet       => const ReportCategoryMeta(icon: Icons.wifi_rounded,            color: Color(0xFF4A148C)),
        ReportCategory.market         => const ReportCategoryMeta(icon: Icons.store_rounded,            color: Color(0xFF6D4C41)),
        ReportCategory.government     => const ReportCategoryMeta(icon: Icons.account_balance_rounded,  color: Color(0xFF283593)),
        ReportCategory.fire           => const ReportCategoryMeta(icon: Icons.local_fire_department_rounded, color: Color(0xFFD84315)),
        ReportCategory.infrastructure => const ReportCategoryMeta(icon: Icons.domain_rounded,           color: Color(0xFF4E342E)),
        ReportCategory.fraud          => const ReportCategoryMeta(icon: Icons.gavel_rounded,            color: Color(0xFF880E4F)),
      };

  static String label(ReportCategory cat, AppLocalizations l10n) => switch (cat) {
        ReportCategory.electricity    => l10n.categoryElectricity,
        ReportCategory.road           => l10n.categoryRoad,
        ReportCategory.flood          => l10n.categoryFlood,
        ReportCategory.security       => l10n.categorySecurity,
        ReportCategory.water          => l10n.categoryWater,
        ReportCategory.health         => l10n.categoryHealth,
        ReportCategory.internet       => l10n.categoryInternet,
        ReportCategory.market         => l10n.categoryMarket,
        ReportCategory.government     => l10n.categoryGovernment,
        ReportCategory.fire           => l10n.categoryFire,
        ReportCategory.infrastructure => l10n.categoryInfrastructure,
        ReportCategory.fraud          => l10n.categoryFraud,
      };
}
