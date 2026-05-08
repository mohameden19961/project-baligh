import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeContent(),
          Center(child: Text('الخريطة', style: TextStyle(color: Colors.white, fontFamily: 'Cairo'))),
          AlertFeedScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/report'),
        backgroundColor: AppTheme.accentGold,
        icon: const Icon(Icons.add, color: AppTheme.primaryGreen, size: 28),
        label: const Text(
          'بلاغ جديد',
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_filled,
                color: _selectedIndex == 0 ? AppTheme.primaryGreen : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.map_outlined,
                color: _selectedIndex == 1 ? AppTheme.primaryGreen : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 48), // Space for FAB
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: _selectedIndex == 2 ? AppTheme.primaryGreen : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
            IconButton(
              icon: Icon(
                Icons.person_outline,
                color: _selectedIndex == 3 ? AppTheme.primaryGreen : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}
