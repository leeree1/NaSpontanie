import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Pobieranie kategorii z tabeli `categories` w Supabase
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select('*');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd podczas pobierania kategorii: $e');
      return [];
    }
  }

  // 1. Nowa metoda zwracająca List<LocationModel>
  Future<List<LocationModel>> getFilteredLocations({
    required String city,
    int? categoryId,
  }) async {
    try {
      var query = _supabase
          .from('locations')
          .select('*')
          .eq('city', city)
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query;
      
      return (response as List)
          .map((json) => LocationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Błąd podczas pobierania lokacji (Model): $e');
      return [];
    }
  }

  // 2. Metoda kompatybilności wstecznej zwracająca surowe Mapy (dla starych miejsc w kodzie)
  Future<List<Map<String, dynamic>>> getFilteredLocationsAsMaps({
    required String city,
    int? categoryId,
  }) async {
    try {
      var query = _supabase
          .from('locations')
          .select('*')
          .eq('city', city)
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd podczas pobierania lokacji (Maps): $e');
      return [];
    }
  }

  // Pobieranie pozycji GPS użytkownika
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