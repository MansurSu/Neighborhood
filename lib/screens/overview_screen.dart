import 'package:flutter/material.dart';
import '../classes/device_model.dart';
import 'add_device_screen.dart'; 

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = [
      Device(
        name: 'Washing Machine',
        description: 'A powerful washing machine for your laundry.',
        imageUrl: 'image_url', 
        price: 5.0,
        available: true,
        category: 'Appliance',
        location: 'Location 1',
      ),
      Device(
        name: 'Fridge',
        description: 'A large fridge with ample storage space.',
        imageUrl: 'image_url', 
        price: 8.0,
        available: true,
        category: 'Appliance',
        location: 'Location 2',
      ),
      Device(
        name: 'Microwave',
        description: 'A microwave for quick heating and cooking.',
        imageUrl: 'image_url',
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
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Device', 
      ),
    );
  }
}
