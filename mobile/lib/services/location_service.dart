import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LocationModel>> getFilteredLocations({
    required String city,
  }) async {
    try {
      final response = await _supabase
          .from('locations')
          .select('*')
          .eq('city', city)
          .eq('is_active', true);

      return (response as List)
          .map((json) => LocationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Błąd podczas pobierania lokacji (Model): $e');
      return [];
    }
  }

  Future<Position?> getMyPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
