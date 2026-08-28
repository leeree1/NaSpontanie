import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const _positionSettings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 8),
  );

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
}
