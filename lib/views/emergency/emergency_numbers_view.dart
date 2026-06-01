// MVC - View
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

class EmergencyNumbersView extends StatelessWidget {
  const EmergencyNumbersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final contacts = [
      _EmergencyContact(
        icon: Icons.local_police_rounded,
        label: l10n.emergencyPolice,
        dial: '17',
        color: const Color(0xFF1565C0),
      ),
      _EmergencyContact(
        icon: Icons.shield_rounded,
        label: l10n.emergencyGendarmerie,
        dial: '12',
        color: const Color(0xFF37474F),
      ),
      _EmergencyContact(
        icon: Icons.fire_extinguisher_rounded,
        label: l10n.emergencyFire,
        dial: '18',
        color: const Color(0xFFEF6C00),
      ),
      _EmergencyContact(
        icon: Icons.local_hospital_rounded,
        label: l10n.emergencyAmbulance,
        dial: '15',
        color: const Color(0xFFC62828),
      ),
      _EmergencyContact(
        icon: Icons.local_hotel_rounded,
        label: l10n.emergencyNationalHospital,
        dial: '224525',
        display: '22 45 25',
        color: const Color(0xFF2E7D32),
      ),
      _EmergencyContact(
        icon: Icons.bolt_rounded,
        label: l10n.emergencyElectricity,
        dial: '904523',
        display: '90 45 23',
        color: const Color(0xFFF9A825),
      ),
      _EmergencyContact(
        icon: Icons.water_drop_rounded,
        label: l10n.emergencyWater,
        dial: '504529',
        display: '50 45 29',
        color: const Color(0xFF0277BD),
      ),
      _EmergencyContact(
        icon: Icons.location_city_rounded,
        label: l10n.emergencyMunicipality,
        dial: '104525',
        display: '10 45 25',
        color: const Color(0xFF6A1B9A),
      ),
      _EmergencyContact(
        icon: Icons.child_care_rounded,
        label: l10n.emergencyChildProtection,
        dial: '116',
        color: const Color(0xFFE91E63),
      ),
      _EmergencyContact(
        icon: Icons.gavel_rounded,
        label: l10n.emergencyAntiCorruption,
        dial: '994525',
        display: '99 45 25',
        color: const Color(0xFFD84315),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.emergencyTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _EmergencyTile(
          icon: contacts[index].icon,
          label: contacts[index].label,
          number: contacts[index].display ?? contacts[index].dial,
          dial: contacts[index].dial,
          color: contacts[index].color,
          theme: theme,
          l10n: l10n,
        ),
      ),
    );
  }
}

class _EmergencyContact {
  final IconData icon;
  final String label;
  final String dial;
  final String? display;
  final Color color;

  const _EmergencyContact({
    required this.icon,
    required this.label,
    required this.dial,
    this.display,
    required this.color,
  });
}

class _EmergencyTile extends StatelessWidget {
  const _EmergencyTile({
    required this.icon,
    required this.label,
    required this.number,
    required this.dial,
    required this.color,
    required this.theme,
    required this.l10n,
  });

  final IconData icon;
  final String label;
  final String number;
  final String dial;
  final Color color;
  final ThemeData theme;
  final AppLocalizations l10n;

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _call(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: color.withOpacity(0.25), width: 1.5),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        number,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        l10n.emergencyCall,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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

  Future<void> _call(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse('tel:${dial.replaceAll(' ', '')}');
    try {
      await launchUrl(uri);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.unknownError),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
