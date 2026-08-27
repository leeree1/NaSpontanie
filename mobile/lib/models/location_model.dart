class LocationModel {
  final int id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final int radius;
  final int xp;
  final double rating;
  final int? categoryId;

  LocationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.xp,
    required this.rating,
    this.categoryId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? 'Miejsce',
      description: json['description']?.toString() ?? '',
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(
        json['longtitude'] ?? json['longitude'] ?? json['lng'] ?? json['lon'],
      ),
      radius: json['radius'] != null ? int.tryParse(json['radius'].toString()) ?? 100 : 100,
      xp: json['location_xp'] != null ? int.tryParse(json['location_xp'].toString()) ?? 150 : 150,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 5.0,
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longtitude': longitude,
      'radius': radius,
      'location_xp': xp,
      'rating': rating,
      'category_id': categoryId,
    };
  }
}