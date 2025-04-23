class Device {
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool available;
  final String category;
  final String location;
  final double latitude;
  final double longitude;

  Device({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.available,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'available': available,
      'category': category,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      available: map['available'],
      category: map['category'],
      location: map['location'] ?? 'Unknown',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }
}
