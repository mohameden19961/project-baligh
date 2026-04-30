import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ma Première Page'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Bienvenue sur ma page !', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
