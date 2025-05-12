import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/device_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class RentedDevicesScreen extends StatelessWidget {
  const RentedDevicesScreen({super.key});

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
              final deviceId = reservation['deviceId'];
              final startDate = DateTime.parse(reservation['start']);
              final endDate = DateTime.parse(reservation['end']);

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('devices')
                        .doc(deviceId)
                        .get(),
                builder: (context, deviceSnapshot) {
                  if (!deviceSnapshot.hasData) {
                    return const ListTile(title: Text('Laden...'));
                  }

                  final deviceData = deviceSnapshot.data!;
                  final device = Device.fromMap(
                    deviceData.data() as Map<String, dynamic>,
                  );

                  return ListTile(
                    leading:
                        device.imageUrl.isNotEmpty
                            ? Image.memory(
                              base64Decode(device.imageUrl),
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.devices),
                    title: Text(device.name),
                    subtitle: Text(
                      'Van: ${startDate.toLocal().toString().split(' ')[0]} '
                      'tot: ${endDate.toLocal().toString().split(' ')[0]}',
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
