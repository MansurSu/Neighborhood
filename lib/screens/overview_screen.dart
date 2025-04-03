import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/device_model.dart';
import 'add_device_screen.dart';
import 'device_detail_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Device> _searchResults = [];
  bool _isSearching = false;

  final List<String> categories = const [
    'Tools & DIY',
    'Party & Events',
    'Sports & Outdoor',
    'Electronics',
    'Home Appliances',
  ];

  void _searchDevices(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final result = await FirebaseFirestore.instance
        .collection('devices')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    final devices = result.docs
        .map((doc) => Device.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    setState(() {
      _isSearching = true;
      _searchResults = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Zoek naar een apparaat... 🔍',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _isSearching = false;
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _searchDevices(_searchController.text),
                  icon: const Icon(Icons.search),
                  label: const Text("Zoek"),
                )
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final device = _searchResults[index];
                      return ListTile(
                        title: Text(device.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceDetailScreen(device: device),
                            ),
                          );
                        },
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        title: Text(category),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemListScreen(categoryName: category),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ItemListScreen extends StatelessWidget {
  final String categoryName;

  const ItemListScreen({Key? key, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devices')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Geen items in deze categorie'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final device = Device.fromMap(doc.data() as Map<String, dynamic>);

              return ListTile(
                title: Text(device.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceDetailScreen(device: device),
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