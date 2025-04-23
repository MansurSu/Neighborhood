import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../classes/device_model.dart';
import 'device_detail_screen.dart';

class OverviewMapScreen extends StatefulWidget {
  const OverviewMapScreen({super.key});

  @override
  State<OverviewMapScreen> createState() => _OverviewMapScreenState();
}

class _OverviewMapScreenState extends State<OverviewMapScreen> {
  List<Device> _searchResults = [];

  //add markers with the location of the devices to the map
  List<Marker> _createMarkers(List<Device> devices) {
    return devices.map((device) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(device.latitude, device.longitude),
        child: IconButton(
          icon: Icon(Icons.location_on),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceDetailScreen(device: device),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('devices').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Geen items in deze categorie'));
        }

        final docs = snapshot.data!.docs;
        final devices =
            docs
                .map(
                  (doc) => Device.fromMap(doc.data() as Map<String, dynamic>),
                )
                .toList();
        _searchResults = devices;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                51.509364,
                -0.128928,
              ), // Center the map over London
              initialZoom: 9.2,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: _createMarkers(_searchResults)),
            ],
          );
        }
      },
    );
  }
}
