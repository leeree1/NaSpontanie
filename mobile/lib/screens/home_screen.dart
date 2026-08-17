import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askAndLoad();
    });
  }

  Future<void> _askAndLoad() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lokalizacja'),
          content: const Text(
            'Potrzebujemy Twojej lokalizacji, żeby liczyć odległość do miejsc. Zgadzasz się?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nie'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tak'),
            ),
          ],
        );
      },
    );

    if (ok != true) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final position = await _locationService.getMyPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });

    if (!mounted) {
      return;
    }

    if (position != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Twoja lokalizacja: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brak zgody na lokalizację albo GPS jest wyłączony.'),
        ),
      );
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
                        : 'Brak lokalizacji. Włącz GPS i daj zgodę w telefonie.',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Lista punktów z bazy
                Expanded(
                  child: FutureBuilder(
                    future: _locationService.getLocations(),
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
                          double lon = (loc['longitude'] as num?)?.toDouble() ??
                              (loc['longtitude'] as num?)?.toDouble() ??
                              0.0;

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
