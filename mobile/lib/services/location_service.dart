import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';

class LiveVibeInfo {
  final String categoryKey;
  final String categoryName;
  final int occupancyPercent;
  final String statusText;
  final bool isHot;
  final Color accentColor;
  final IconData icon;

  LiveVibeInfo({
    required this.categoryKey,
    required this.categoryName,
    required this.occupancyPercent,
    required this.statusText,
    required this.isHot,
    required this.accentColor,
    required this.icon,
  });
}

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Pobiera listę lokacji z bazy Supabase
  Future<List<LocationModel>> getFilteredLocations({
    String? city,
    String? transportType,
    double? maxBudget,
    int? maxTimeMinutes,
  }) async {
    try {
      var query = _supabase.from('locations').select();

      if (city != null) {
        query = query.eq('city', city);
      }

      final response = await query;

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => LocationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Błąd pobierania punktów z bazy: $e');
      return [];
    }
  }

  /// Losuje wybraną liczbę punktów do trasy (PoC #14)
  Future<List<LocationModel>> getRandomTripLocations(
    int count, {
    String? city,
    String? transportType,
    double? maxBudget,
    int? maxTimeMinutes,
  }) async {
    try {
      List<LocationModel> allLocations = await getFilteredLocations(
        city: city,
        transportType: transportType,
        maxBudget: maxBudget,
        maxTimeMinutes: maxTimeMinutes,
      );

      if (allLocations.isEmpty) return [];

      allLocations.shuffle();
      return allLocations.take(count).toList();
    } catch (e) {
      debugPrint('Błąd losowania: $e');
      return [];
    }
  }

  /// Oblicza wskaźnik ruchu i atmosferę na żywo w oparciu o zegar i profil miejsca
  LiveVibeInfo calculateLiveVibe(int locationId) {
    final now = DateTime.now();
    final hour = now.hour;
    final isWeekend = now.weekday >= 5; // Piątek - Niedziela
    final mod = locationId % 4;

    if (mod == 0) {
      // Wrocław Nocą (Kluby, puby, neony)
      int occupancy = (hour >= 20 || hour <= 3) ? (isWeekend ? 92 : 72) : 15;
      return LiveVibeInfo(
        categoryKey: 'night',
        categoryName: 'Wrocław Nocą',
        occupancyPercent: occupancy,
        statusText: occupancy >= 70 ? '🔥 Pełny parkiet / Szczyt' : 'Czeka na wieczór',
        isHot: occupancy >= 70,
        accentColor: AppColors.fireOrange,
        icon: Icons.nightlife_rounded,
      );
    } else if (mod == 1) {
      // Kawa i Chill (Kawiarnie, bistro, strefy gastro)
      int occupancy = (hour >= 11 && hour <= 16) ? 82 : (hour < 9 ? 10 : 38);
      return LiveVibeInfo(
        categoryKey: 'chill',
        categoryName: 'Kawa i Chill',
        occupancyPercent: occupancy,
        statusText: occupancy >= 75 ? 'Sporo gości • Zapach kawy' : '🌿 Spokojne stoliki',
        isHot: occupancy >= 75,
        accentColor: const Color(0xFF0284C7),
        icon: Icons.coffee_rounded,
      );
    } else if (mod == 2) {
      // Ukryte Perełki (Ciche zaułki, podwórka, galerie)
      int occupancy = (hour >= 12 && hour <= 19) ? 42 : 12;
      return LiveVibeInfo(
        categoryKey: 'gems',
        categoryName: 'Ukryte Perełki',
        occupancyPercent: occupancy,
        statusText: '✨ Kameralna atmosfera',
        isHot: false,
        accentColor: const Color(0xFF10B981),
        icon: Icons.auto_awesome_rounded,
      );
    } else {
      // Zabytki i Mosty (Ostrów, ikony architektury)
      int occupancy = (hour >= 10 && hour <= 18) ? 68 : 20;
      return LiveVibeInfo(
        categoryKey: 'sights',
        categoryName: 'Zabytki i Mosty',
        occupancyPercent: occupancy,
        statusText: occupancy >= 60 ? 'Ruch spacerowy' : 'Cisza nad rzeką',
        isHot: false,
        accentColor: const Color(0xFF8B5CF6),
        icon: Icons.account_balance_rounded,
      );
    }
  }

  /// Zapis oceny atmosfery przez użytkownika (Crowdsourcing)
  Future<void> submitLiveFeedback(int locationId, String crowdStatus) async {
    debugPrint('Zgłoszono vibe dla punktu $locationId: $crowdStatus');
    // Tutaj można dodać wpis do tabeli live_feedback w Supabase
  }

  /// Pobiera GPS urządzenia
  Future<Position?> getMyPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Błąd GPS: $e');
      return null;
    }
  }
}