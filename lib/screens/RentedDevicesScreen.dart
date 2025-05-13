import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentedDevicesScreen extends StatelessWidget {
  const RentedDevicesScreen({super.key});

  Future<void> cancelReservation(String reservationId, String deviceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .delete();

      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .update({'available': true});
    } catch (e) {
      print('Error during cancellation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My rented devices')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('reservations')
                .where('userId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No devices.'),
            );
          }

          final reservations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final reservationId = reservation.id;
              final deviceId = reservation['deviceId'];

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('devices')
                        .doc(deviceId)
                        .get(),
                builder: (context, deviceSnapshot) {
                  if (deviceSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('Device not found'),
                    );
                  }

                  final deviceData =
                      deviceSnapshot.data!.data() as Map<String, dynamic>;
                  final deviceName = deviceData['name'] ?? 'Uknown Device';

                  return ListTile(
                    title: Text(deviceName),
                    trailing: OutlinedButton(
                      onPressed: () async {
                        await cancelReservation(reservationId, deviceId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item returned successfully'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red, 
                        side: const BorderSide(color: Colors.red), 
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      child: const Text('Return'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
