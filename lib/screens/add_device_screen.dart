import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../classes/device_model.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String imageBase64 = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedCategory = 'Tools & DIY';

  final List<String> categories = [
    'Tools & DIY',
    'Party & Events',
    'Sports & Outdoor',
    'Electronics',
    'Home Appliances',
  ];

  void addImage() {
    final ImagePicker picker = ImagePicker();
    picker.pickImage(source: ImageSource.gallery).then((pickedFile) async {
      if (pickedFile != null) {
        List<int> imageBytes = await pickedFile.readAsBytes();
        setState(() {
          imageBase64 = base64Encode(imageBytes);
        });
      }
    });
  }

  Future<void> addDevice() async {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul alle velden correct in')),
      );
      return;
    }

    double? parsedPrice = double.tryParse(priceController.text.trim());
    if (parsedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prijs moet een getal zijn')),
      );
      return;
    }

    if (imageBase64.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Voeg een afbeelding toe')));
      return;
    }

    try {
      final location = locationController.text.trim();
      final request = await http.get(
        Uri.parse(
          "https://nominatim.openstreetmap.org/search.php?q=${location.replaceAll(" ", "+")}&format=jsonv2",
        ),
      );
      final device = Device(
        id: _firestore.collection('devices').doc().id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        imageUrl: imageBase64,
        price: parsedPrice,
        available: true,
        category: selectedCategory,
        location: location,
        latitude: double.parse(jsonDecode(request.body)[0]['lat']),
        longitude: double.parse(jsonDecode(request.body)[0]['lon']),
      );
      await _firestore.collection('devices').doc(device.id).set(device.toMap());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Device toegevoegd!')));
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Er ging iets mis bij het toevoegen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apparaat toevoegen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Naam'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Beschrijving'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prijs'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Categorie'),
                items:
                    categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Locatie'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addImage,
                child: const Text('Afbeelding kiezen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addDevice,
                child: const Text('Toevoegen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
