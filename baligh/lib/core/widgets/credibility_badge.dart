import 'package:flutter/material.dart';

class CredibilityBadge extends StatelessWidget {
  final int score;

  const CredibilityBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 80) {
      color = Colors.green;
    } else if (score >= 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
