import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
  return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
}

  // Funkcja pobierająca listę punktów z bazy
  Future<List<Map<String, dynamic>>> getLocations() async {
    final response = await _supabase.from('locations').select('*');
    return response;
  }
}