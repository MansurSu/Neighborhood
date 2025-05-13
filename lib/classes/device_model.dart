class Device {
  final String id; // Nieuw id-veld toegevoegd
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool available;
  final String category;
  final String location;
  final double latitude;
  final double longitude;
  final String ownerId;

  Device({
    required this.id, // id toegevoegd aan de constructor
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.available,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // id toegevoegd aan de map
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'available': available,
      'category': category,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': ownerId,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Onbekend apparaat',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      available: map['available'] ?? false,
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      ownerId: map['ownerId'] ?? '',
    );
  }
}
