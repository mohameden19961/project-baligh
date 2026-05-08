import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text('Interactive Map View Feed', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Full Map View Placeholder'));
  }
}
