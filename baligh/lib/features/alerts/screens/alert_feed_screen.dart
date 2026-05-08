import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/alert_card.dart';
import '../../../core/theme/app_theme.dart';

class AlertFeedScreen extends StatelessWidget {
  const AlertFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockAlerts = [
      {
        'id': '1',
        'title': 'انقطاع تيار كهربائي',
        'neighborhood': 'تفرغ زينة',
        'time': 'منذ 10 دقائق',
        'icon': Icons.bolt,
        'credibility': 92,
      },
      {
        'id': '2',
        'title': 'كسر في أنبوب مياه',
        'neighborhood': 'القصار',
        'time': 'منذ 35 دقيقة',
        'icon': Icons.opacity,
        'credibility': 75,
      },
      {
        'id': '3',
        'title': 'حفرة في الطريق',
        'neighborhood': 'عرفات',
        'time': 'منذ ساعة',
        'icon': Icons.directions_car,
        'credibility': 45,
      },
      {
        'id': '4',
        'title': 'تجمع نفايات',
        'neighborhood': 'دار النعيم',
        'time': 'منذ ساعتين',
        'icon': Icons.delete_outline,
        'credibility': 88,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'تغذية البلاغات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockAlerts.length,
        itemBuilder: (context, index) {
          final alert = mockAlerts[index];
          return AlertCard(
            categoryIcon: alert['icon'],
            title: alert['title'],
            neighborhood: alert['neighborhood'],
            time: alert['time'],
            credibility: alert['credibility'],
            onTap: () => context.push('/alert-detail/${alert['id']}'),
          );
        },
      ),
    );
  }
}

