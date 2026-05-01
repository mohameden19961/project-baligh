import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/alert_card.dart';

class AlertFeedScreen extends StatelessWidget {
  const AlertFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockAlerts = [
      {
        'id': '1',
        'title': 'Power Outage',
        'neighborhood': 'Tevragh Zeina',
        'time': '10 mins ago',
        'icon': Icons.bolt,
        'credibility': 92,
      },
      {
        'id': '2',
        'title': 'Broken Water Pipe',
        'neighborhood': 'Ksar',
        'time': '35 mins ago',
        'icon': Icons.opacity,
        'credibility': 75,
      },
      {
        'id': '3',
        'title': 'Road Damage',
        'neighborhood': 'Arafat',
        'time': '1 hour ago',
        'icon': Icons.directions_car,
        'credibility': 45,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
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
