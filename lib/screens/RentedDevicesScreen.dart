import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentedDevicesScreen extends StatelessWidget {
  const RentedDevicesScreen({super.key});

  Future<void> cancelReservation(String reservationId, String deviceId) async {
    try {
      // Verwijder de reservering uit de reservations-collectie
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .delete();

      // Zet het apparaat weer beschikbaar in de devices-collectie
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .update({'available': true});
    } catch (e) {
      print('Error bij annuleren: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mijn Gehuurde Toestellen')),
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
              child: Text('Je hebt nog geen toestellen gehuurd.'),
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
                    return const ListTile(title: Text('Laden...'));
                  }

                  if (!deviceSnapshot.hasData || !deviceSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('Apparaat niet gevonden'),
                    );
                  }

                  final deviceData =
                      deviceSnapshot.data!.data() as Map<String, dynamic>;
                  final deviceName = deviceData['name'] ?? 'Onbekend apparaat';

                  return ListTile(
                    title: Text(deviceName),
                    trailing: OutlinedButton(
                      onPressed: () async {
                        await cancelReservation(reservationId, deviceId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reservering geannuleerd'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red, // Tekstkleur
                        side: const BorderSide(color: Colors.red), // Randkleur
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
