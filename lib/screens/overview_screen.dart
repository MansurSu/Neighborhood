import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: const Center(
        child: Text(
          'Welkom op het Overview-scherm!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
