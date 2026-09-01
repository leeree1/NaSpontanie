import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../providers/app_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/maptiler_map.dart';
import 'map_walk_controls.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _fallbackLocation = LatLng(51.1097, 17.0325);
  static const Distance _distanceCalculator = Distance();
  static const double _unlockRadiusMeters = 25.0;

  final LocationService _locationService = LocationService();
  List<MapPoi> _pois = const [];
  LatLng _userLocation = _fallbackLocation;
  var _hasWalked = false;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadLocations(),
      _loadUserLocation(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _locationService.getFilteredLocations(
        city: 'Wrocław',
      );
      if (!mounted) return;
      setState(() {
        _pois = _toPois(locations);
      });
      _checkNearbyPois();
    } catch (e) {
      if (!mounted) return;
      debugPrint('Błąd pobierania lokacji na mapę: $e');
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await _locationService.getMyPosition();
      if (!mounted || position == null || _hasWalked) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _checkNearbyPois();
    } catch (_) {}
  }

  void _walk(WalkDirection direction) {
    setState(() {
      _hasWalked = true;
      _userLocation = SimulatedWalk.step(_userLocation, direction);
    });
    _checkNearbyPois();
  }

  /// Sprawdza odległość i odblokowuje miejsce w globalnym AppProviderze
  void _checkNearbyPois() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    for (var poi in _pois) {
      final meters = _distanceCalculator.as(
        LengthUnit.Meter,
        _userLocation,
        poi.point,
      );

      if (meters <= _unlockRadiusMeters) {
        if (!appProvider.isUnlocked(poi.id)) {
          // Odblokowujemy w stanie globalnym i dajemy 150 XP
          appProvider.unlockLocation(poi.id, xpReward: 150);
          _showUnlockedSnackBar(poi.title);
        }
      }
    }
  }

  void _showUnlockedSnackBar(String poiTitle) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Zdobyto miejsce: "$poiTitle"! 🎉 (+150 XP)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetToUserLocation() async {
    setState(() => _isLoading = true);
    await _loadUserLocation();
    setState(() {
      _hasWalked = false;
      _isLoading = false;
    });
  }

  List<MapPoi> _toPois(List<LocationModel> locations) {
    return locations
        .where((location) {
          final lat = location.latitude;
          final lng = location.longitude;
          if (lat == 0 && lng == 0) return false;
          return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
        })
        .map(
          (location) => MapPoi(
            id: 'location-${location.id}',
            title: location.title,
            point: LatLng(location.latitude, location.longitude),
            description: location.description,
            xp: location.xp,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Eksploracja Miasta',
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centruj GPS',
            onPressed: _resetToUserLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          MapTilerMap(
            pois: _pois,
            userLocation: _userLocation,
            initialCenter: _userLocation,
            initialZoom: 16.5,
          ),
          if (_isLoading)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Ładowanie mapy...', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          Positioned(
            left: 16,
            bottom: 24,
            child: MapWalkPad(onStep: _walk),
          ),
        ],
      ),
    );
  }
}