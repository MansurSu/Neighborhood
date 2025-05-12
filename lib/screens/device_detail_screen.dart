import 'package:flutter/material.dart';
import 'dart:convert'; // Voor base64Decode
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/device_model.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> reserveDevice() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecteer een periode voordat je reserveert.'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('reservations').add({
      'deviceId': widget.device.id,
      'start': startDate!.toIso8601String(),
      'end': endDate!.toIso8601String(),
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Toestel gereserveerd! 🎉')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Afbeelding van het apparaat
            if (widget.device.imageUrl.isNotEmpty)
              Center(
                child:
                    widget.device.imageUrl != "image_url"
                        ? Image.memory(
                          base64Decode(widget.device.imageUrl),
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                        : const Text(
                          'Geen afbeelding beschikbaar',
                          style: TextStyle(fontSize: 18),
                        ),
              ),
            const SizedBox(height: 20),

            // Beschrijving van het apparaat
            Text(
              'Beschrijving: ${widget.device.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Prijs
            Text(
              'Prijs: €${widget.device.price.toStringAsFixed(2)} per dag',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Beschikbaarheid
            Text(
              widget.device.available ? 'Beschikbaar' : 'Niet beschikbaar',
              style: TextStyle(
                fontSize: 16,
                color: widget.device.available ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),

            // Categorie
            Text(
              'Categorie: ${widget.device.category}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Locatie
            Text(
              'Locatie: ${widget.device.location}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Knop om een periode te kiezen
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now,
                  lastDate: DateTime(now.year + 1),
                );

                if (picked != null) {
                  setState(() {
                    startDate = picked.start;
                    endDate = picked.end;
                  });
                }
              },
              child: const Text('Kies periode'),
            ),

            // Geselecteerde datums weergeven
            if (startDate != null && endDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Van: ${startDate!.toLocal().toString().split(' ')[0]} '
                  'tot: ${endDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),

            // Knop om te reserveren
            ElevatedButton(
              onPressed: reserveDevice,
              child: const Text('Reserveer'),
            ),
          ],
        ),
      ),
    );
  }
}
