import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('TODAY'),
          _buildNotificationItem(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            title: 'Report Confirmed',
            body: 'Your report on "Broken Water Pipe" has been confirmed by 50 citizens.',
            time: '2h ago',
          ),
          _buildNotificationItem(
            icon: Icons.warning_amber_outlined,
            color: Colors.orange,
            title: 'New Alert Nearby',
            body: 'A security issue was reported 500m from your current location.',
            time: '5h ago',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('YESTERDAY'),
          _buildNotificationItem(
            icon: Icons.star_outline,
            color: Colors.blue,
            title: 'Level Up!',
            body: 'Congratulations! You are now a "Trusted Contributor".',
            time: '1d ago',
            isRead: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    required String time,
    bool isRead = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isRead ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
