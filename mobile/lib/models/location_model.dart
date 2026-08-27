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
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radius: json['radius'] != null ? int.tryParse(json['radius'].toString()) ?? 100 : 100,
      xp: json['location_xp'] != null ? int.tryParse(json['location_xp'].toString()) ?? 150 : 150,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 5.0,
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'location_xp': xp,
      'rating': rating,
      'category_id': categoryId,
    };
  }
}