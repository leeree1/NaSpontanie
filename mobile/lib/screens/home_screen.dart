import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentPosition = Position(
          latitude: 51.1079,
          longitude: 17.0385,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NaSpontanie - Wrocław')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Panel informacyjny z Twoją aktualną lokalizacją GPS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  color: Colors.blue.shade50,
                  child: Text(
                    _currentPosition != null
                        ? 'Twoja lokalizacja:\nSzerokość: ${_currentPosition!.latitude.toStringAsFixed(4)}\nDługość: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                        : 'Brak danych o lokalizacji',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Lista punktów z bazy
                Expanded(
                  child: FutureBuilder(
                    future: LocationService().getLocations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final locations = snapshot.data as List<Map<String, dynamic>>? ?? [];

                      if (locations.isEmpty) {
                        return const Center(child: Text('Brak punktów w bazie.'));
                      }

                      return ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final loc = locations[index];
                          
                          double lat = (loc['latitude'] as num?)?.toDouble() ?? 0.0;
                          double lon = (loc['longtitude'] as num?)?.toDouble() ?? 0.0;
                          
                          double distance = 0.0;
                          if (_currentPosition != null) {
                            distance = Geolocator.distanceBetween(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              lat,
                              lon,
                            );
                          }

                          String distanceText = distance >= 1000 
                              ? '${(distance / 1000).toStringAsFixed(1)} km' 
                              : '${distance.toInt()} m';

                          double radius = (loc['radius'] as num?)?.toDouble() ?? 100.0;
                          bool isNear = distance > 0 && distance <= radius;

                          return ListTile(
                            title: Text(loc['title'] ?? 'Bez nazwy'),
                            subtitle: Text('Odległość: $distanceText'),
                            trailing: Icon(
                              isNear ? Icons.check_circle : Icons.location_on,
                              color: isNear ? Colors.green : Colors.grey,
                            ),
                            onTap: () {
                              if (isNear) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Brawo! Jesteś w miejscu: ${loc['title']}')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Za daleko od ${loc['title']}! Dystans: $distanceText')),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}