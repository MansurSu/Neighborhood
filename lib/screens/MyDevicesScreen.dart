import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyDevicesScreen extends StatelessWidget {
  const MyDevicesScreen({super.key});

  Future<void> deleteDevice(String deviceId) async {
    try {
      // Verwijder het apparaat uit de devices-collectie
      await FirebaseFirestore.instance.collection('devices').doc(deviceId).delete();

      // Verwijder ook eventuele reserveringen die aan dit apparaat gekoppeld zijn
      final reservations = await FirebaseFirestore.instance
          .collection('reservations')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      for (var reservation in reservations.docs) {
        await reservation.reference.delete();
      }
    } catch (e) {
      print('Error bij verwijderen van apparaat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Devices'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devices')
            .where('ownerId', isEqualTo: userId) // Filter op apparaten van de ingelogde gebruiker
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have not added any devices yet.'),
            );
          }

          final devices = snapshot.data!.docs;

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final deviceData = device.data() as Map<String, dynamic>;
              final deviceName = deviceData['name'] ?? 'Unknown Device';

              return ListTile(
                title: Text(deviceName),
                subtitle: Text('Category: ${deviceData['category'] ?? 'Unknown'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Device'),
                        content: const Text('Are you sure you want to delete this device?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await deleteDevice(device.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Device deleted successfully')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}