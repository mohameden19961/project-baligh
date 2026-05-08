import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'التنبيهات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('اليوم'),
          _buildNotificationItem(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            title: 'تم تأكيد البلاغ',
            body: 'تم تأكيد بلاغك عن "كسر أنبوب مياه" من قبل 50 مواطناً.',
            time: 'منذ ساعتين',
          ),
          _buildNotificationItem(
            icon: Icons.warning_amber_outlined,
            color: Colors.orange,
            title: 'بلاغ جديد قريب منك',
            body: 'تم التبليغ عن مشكلة أمنية على بعد 500 متر من موقعك الحالي.',
            time: 'منذ 5 ساعات',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('أمس'),
          _buildNotificationItem(
            icon: Icons.star_outline,
            color: Colors.blue,
            title: 'ترقية المستوى!',
            body: 'تهانينا! لقد أصبحت الآن "مساهم موثوق" في نظام بلّغ.',
            time: 'منذ يوم',
            isRead: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
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
        color: isRead ? Colors.transparent : AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: isRead ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: AppTheme.darkText,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Cairo', height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

