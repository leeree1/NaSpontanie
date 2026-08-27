import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/location_model.dart';
import '../../services/location_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/maptiler_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  List<MapPoi> _pois = const [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
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
      body: MapTilerMap(pois: _pois),
    );
  }
}
