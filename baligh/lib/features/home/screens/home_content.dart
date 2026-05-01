import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.white),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'بلّغ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.campaign, size: 20, color: Colors.white),
                        ),
                      ],
                    ),
                    const Text(
                      'نواكشوط — 4 بلاغات نشطة',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('آمن', Colors.green, true),
                _buildFilterChip('تنبيه', Colors.orange, false),
                _buildFilterChip('خطر', Colors.red, false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAlertCard(
                      time: 'منذ 10 دقائق',
                      title: 'انقطاع كهرباء',
                      subtitle: 'الكهرباء مقطوعة في حي الرياض منذ ساعتين',
                      icon: Icons.bolt,
                      iconColor: Colors.amber,
                      iconBg: Colors.amber.withOpacity(0.2),
                      upvotes: '12',
                      downvotes: '1',
                    ),
                    _buildAlertCard(
                      time: 'منذ 25 دقيقة',
                      title: 'مشكلة طريق',
                      subtitle: 'حادث عند مفترق كيبه، الطريق مغلق',
                      icon: Icons.directions_car,
                      iconColor: Colors.red,
                      iconBg: Colors.red.withOpacity(0.2),
                      upvotes: '8',
                      downvotes: '0',
                    ),
                    _buildAlertCard(
                      time: 'منذ 1 ساعة',
                      title: 'فيضان / أمطار',
                      subtitle: 'طريق مغمور قرب السوق المركزي',
                      icon: Icons.water_drop,
                      iconColor: Colors.blue,
                      iconBg: Colors.blue.withOpacity(0.2),
                      upvotes: '20',
                      downvotes: '2',
                    ),
                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(radius: 4, backgroundColor: color),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String time,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String upvotes,
    required String downvotes,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'اضغط — تفاصيل البلاغ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(downvotes, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const Icon(Icons.close, color: Colors.red, size: 14),
                  const SizedBox(width: 8),
                  Text(upvotes, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const Icon(Icons.check, color: Colors.green, size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Full Map View Placeholder', style: TextStyle(color: Colors.white)));
  }
}
