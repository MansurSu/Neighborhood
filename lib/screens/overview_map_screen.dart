import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../classes/device_model.dart';
import 'device_detail_screen.dart';

class OverviewMapScreen extends StatefulWidget {
  const OverviewMapScreen({super.key});

  @override
  State<OverviewMapScreen> createState() => _OverviewMapScreenState();
}

class _OverviewMapScreenState extends State<OverviewMapScreen> {
  List<Device> _searchResults = [];
  late LatLng _center;
  late Position currentLocation;
  bool isLoading = true;
  double radius = 5000;
  double zoom = 12;
  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }
    currentLocation = await locateUser();
    setState(() {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    });
    isLoading = false;
  }

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
    return Scaffold(
      appBar: AppBar(title: Text("Map")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('devices').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items found'));
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
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: zoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _center,
                          useRadiusInMeter: true,
                          radius: radius,
                          color: Colors.blue.withValues(alpha: 0.5),
                          borderStrokeWidth: 2,
                          borderColor: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(markers: _createMarkers(_searchResults)),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          ElevatedButton(
                            child: Text("-"),
                            onPressed: () {
                              setState(() {
                                radius *= 2;
                                zoom--;
                              });
                            },
                          ),
                          ElevatedButton(
                            child: Text("+"),
                            onPressed: () {
                              setState(() {
                                radius /= 2;
                                zoom++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("Distance: ${radius / 1000} km"),
                    ),
                  ],
                );
          }
        },
      ),
    );
  }
}
