import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isAvailable = true;
  DateTime? unavailableTill;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final now = DateTime.now();

    final reservations =
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('deviceId', isEqualTo: widget.device.id)
            .get();

    DateTime? latestEndDate;

    for (var reservation in reservations.docs) {
      final start = DateTime.parse(reservation['start']);
      final end = DateTime.parse(reservation['end']);

      if (now.isAfter(start) && now.isBefore(end)) {
        setState(() {
          isAvailable = false;
          unavailableTill =
              end; // Bewaar de einddatum van de huidige reservering
        });
        return;
      }

      if (latestEndDate == null || end.isAfter(latestEndDate)) {
        latestEndDate = end; // Bewaar de laatste einddatum
      }
    }

    setState(() {
      isAvailable = true;
      unavailableTill = latestEndDate; // Laatste einddatum van reserveringen
    });
  }

  Future<void> reserveDevice() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a period before reserving.')),
      );
      return;
    }

    final reservations =
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('deviceId', isEqualTo: widget.device.id)
            .get();

    for (var reservation in reservations.docs) {
      final start = DateTime.parse(reservation['start']);
      final end = DateTime.parse(reservation['end']);

      if (startDate!.isBefore(end) && endDate!.isAfter(start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This device is already reserved for this period.'),
          ),
        );
        return;
      }
    }

    await FirebaseFirestore.instance.collection('reservations').add({
      'deviceId': widget.device.id,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'start': startDate!.toIso8601String(),
      'end': endDate!.toIso8601String(),
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Device rented! 🎉')));

    _checkAvailability(); // Update beschikbaarheid na reservering
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
                          'No image available',
                          style: TextStyle(fontSize: 18),
                        ),
              ),
            const SizedBox(height: 20),

            Text(
              'Description: ${widget.device.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            Text(
              'Price: €${widget.device.price.toStringAsFixed(2)} per day',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text(
              isAvailable
                  ? 'Available'
                  : 'Not available till ${unavailableTill != null ? "${unavailableTill!.day} ${_getMonthName(unavailableTill!.month)}" : ""}',
              style: TextStyle(
                fontSize: 16,
                color: isAvailable ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Category: ${widget.device.category}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            Text(
              'Location: ${widget.device.location}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate:
                      unavailableTill != null && unavailableTill!.isAfter(now)
                          ? unavailableTill!.add(const Duration(days: 1))
                          : now,
                  lastDate: DateTime(now.year + 1),
                );

                if (picked != null) {
                  setState(() {
                    startDate = picked.start;
                    endDate = picked.end;
                  });
                }
              },
              child: const Text('Choose period'),
            ),

            if (startDate != null && endDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'From: ${startDate!.toLocal().toString().split(' ')[0]} '
                  'to: ${endDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: reserveDevice,
              child: const Text('Reserve'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
