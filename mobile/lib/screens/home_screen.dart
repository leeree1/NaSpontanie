import 'package:flutter/material.dart';
import 'mission_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Przykładowa lista miejsc we Wrocławiu ze współrzędnymi geograficznymi
    final List<Map<String, dynamic>> places = [
      {
        'name': 'Sky Tower',
        'latitude': 51.0949,
        'longitude': 17.0162,
        'distance': '0 m', // Miejsce na dane z Twojego serwisu lokalizacji
      },
      {
        'name': 'Hala Stulecia',
        'latitude': 51.1079,
        'longitude': 17.0782,
        'distance': '0 m', // Miejsce na dane z Twojego serwisu lokalizacji
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NaSpontanie - Wrocław'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Górny baner informacyjny o statusie GPS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.blue[50],
            child: const Text(
              'Wybierz cel misji z poniższej listy, aby rozpocząć weryfikację GPS.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          
          // Lista dostępnych atrakcji
          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      place['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Odległość: ${place['distance']}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                    onTap: () {
                      // Po kliknięciu w element przechodzimy do ekranu misji GPS
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MissionScreen(
                            placeName: place['name'],
                            targetLatitude: place['latitude'],
                            targetLongitude: place['longitude'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}