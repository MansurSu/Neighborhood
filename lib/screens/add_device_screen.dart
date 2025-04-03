import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/device_model.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedCategory = 'Tools & DIY';

  final List<String> categories = [
    'Tools & DIY',
    'Party & Events',
    'Sports & Outdoor',
    'Electronics',
    'Home Appliances',
  ];

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

    try {
      final device = Device(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        imageUrl: 'image_url',
        price: parsedPrice,
        available: true,
        category: selectedCategory,
        location: locationController.text.trim(),
      );

      await _firestore.collection('devices').add(device.toMap());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Device toegevoegd!')));
      Navigator.pop(context);
    } catch (e) {
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
