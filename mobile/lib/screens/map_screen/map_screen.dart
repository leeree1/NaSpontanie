import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/location_model.dart';
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

  final LocationService _locationService = LocationService();
  List<MapPoi> _pois = const [];
  LatLng _userLocation = _fallbackLocation;
  var _hasWalked = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _loadUserLocation();
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pois = const [];
      });
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await _locationService.getMyPosition();
      if (!mounted || position == null || _hasWalked) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (_) {
      // Zostaje pozycja startowa — chód testowy i tak działa.
    }
  }

  void _walk(WalkDirection direction) {
    setState(() {
      _hasWalked = true;
      _userLocation = SimulatedWalk.step(_userLocation, direction);
    });
  }

  List<MapPoi> _toPois(List<LocationModel> locations) {
    return locations
        .where((location) => location.latitude != 0 || location.longitude != 0)
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
      appBar: const AppHeader(title: 'Mapa'),
      body: Stack(
        children: [
          MapTilerMap(
            pois: _pois,
            userLocation: _userLocation,
            initialCenter: _userLocation,
            initialZoom: 16.5,
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
