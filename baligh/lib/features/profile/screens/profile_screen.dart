import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF1E1E1E),
              child: Icon(Icons.person, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Abdy El Housseine',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Text(
                'Trusted Contributor',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                _buildStatItem('Reports', '24'),
                _buildStatItem('Confirmed', '88%'),
                _buildStatItem('Reputation', '450'),
              ],
            ),
            const SizedBox(height: 48),
            _buildProfileOption(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: () => context.push('/edit-profile'),
            ),
            _buildProfileOption(
              icon: Icons.history,
              label: 'My Reports History',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.notifications_none,
              label: 'Notification Settings',
              onTap: () => context.push('/settings'),
            ),
            _buildProfileOption(
              icon: Icons.logout,
              label: 'Logout',
              color: Colors.red,
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: color ?? Colors.white),
        title: Text(label, style: TextStyle(color: color ?? Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      ),
    );
  }
}
