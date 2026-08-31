import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const _positionSettings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 8),
  );

  /// Pobiera przefiltrowane lokacje z bazy Supabase dla wybranego miasta
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
      debugPrint('Błąd podczas pobierania lokacji (Model): $e');
      return [];
    }
  }

  /// Pobiera bieżącą pozycję użytkownika za pomocą GPS z obsługą uprawnień
  Future<Position?> getMyPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: _positionSettings,
        );
      } on TimeoutException {
        return Geolocator.getLastKnownPosition();
      }
    } catch (e) {
      debugPrint('Błąd GPS: $e');
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Proof of Concept (Zadanie #14): Losuje określoną liczbę lokacji z pliku assets/locations.json
  Future<List<LocationModel>> getRandomTripLocations(int count) async {
    try {
      final String response = await rootBundle.loadString('assets/locations.json');
      final List<dynamic> data = json.decode(response);

      // Losowanie bezpośrednio na liście danych surowych przed mapowaniem
      data.shuffle(Random());
      final selectedData = data.take(count);

      List<LocationModel> locations = selectedData.map((jsonItem) {
        return LocationModel.fromJson({
          'id': jsonItem['id'].toString(),
          'name': jsonItem['name'],
          'lat': jsonItem['lat'],
          'lon': jsonItem['lon'],
        });
      }).toList();

      return locations;
    } catch (e) {
      debugPrint('Błąd podczas losowania lokacji do planera (#14): $e');
      return [];
    }
  }
}