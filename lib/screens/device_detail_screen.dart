import 'package:flutter/material.dart';
import '../classes/device_model.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Beschrijving: ${device.description}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Prijs: €${device.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Categorie: ${device.category}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Locatie: ${device.location}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Beschikbaar: ${device.available ? 'Ja' : 'Nee'}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
