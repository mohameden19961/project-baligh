import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baligh/core/l10n/generated/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_content.dart';
import '../../alerts/screens/alert_feed_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeContent(), // This will be the Map View with markers
    MapPlaceholder(), // Simple map view
    AlertFeedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
           const HomeContent(),
           const MapPlaceholder(),
           const AlertFeedScreen(),
           const ProfileScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1 
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/report'),
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(l10n.reportNow, style: const TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.map_outlined), label: l10n.map),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications_outlined), label: l10n.alerts),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
        ],
      ),
    );
  }
}

