import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/credibility_badge.dart';

class AlertDetailScreen extends StatelessWidget {
  final String id;

  const AlertDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.map, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Power Outage',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const CredibilityBadge(score: 92),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('10 mins ago', style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 16),
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Tevragh Zeina', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The power has been out in the entire block since 9:00 PM. Several neighbors have confirmed this issue.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Photos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Community Validation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(
                    value: 0.92,
                    backgroundColor: Colors.red,
                    color: Colors.green,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('92 Confirmations', style: TextStyle(color: Colors.green, fontSize: 12)),
                      Text('8 False Reports', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 48),
                  AppButton(
                    text: 'Confirm this issue',
                    backgroundColor: Colors.green.withOpacity(0.8),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Mark as false report',
                    backgroundColor: Colors.red.withOpacity(0.8),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
