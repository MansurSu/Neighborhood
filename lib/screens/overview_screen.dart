import 'package:flutter/material.dart';
import '../classes/device_model.dart'; // Zorg ervoor dat deze import klopt

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Maak een lijst van devices die je wil hardcoden
    final devices = [
      Device(
        name: 'Washing Machine',
        description: 'A powerful washing machine for your laundry.',
        imageUrl:
            'image_url', // Voeg hier een daadwerkelijke afbeelding toe als je wil
        price: 5.0,
        available: true,
        category: 'Appliance',
        location: 'Location 1',
      ),
      Device(
        name: 'Fridge',
        description: 'A large fridge with ample storage space.',
        imageUrl:
            'image_url', // Voeg hier een daadwerkelijke afbeelding toe als je wil
        price: 8.0,
        available: true,
        category: 'Appliance',
        location: 'Location 2',
      ),
      Device(
        name: 'Microwave',
        description: 'A microwave for quick heating and cooking.',
        imageUrl:
            'image_url', // Voeg hier een daadwerkelijke afbeelding toe als je wil
        price: 3.0,
        available: true,
        category: 'Appliance',
        location: 'Location 3',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.description),
            trailing: Text('\$${device.price}'),
            onTap: () {
              // Add logic to interact with the device (e.g., reserve)
            },
          );
        },
      ),
    );
  }
}
