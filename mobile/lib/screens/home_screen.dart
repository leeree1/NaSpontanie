import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mission_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Funkcja pobierająca miejsca z tabeli 'locations' w Supabase
  Future<List<Map<String, dynamic>>> _fetchLocations() async {
    final response = await Supabase.instance.client
        .from('locations') // Nazwa tabeli w Twojej bazie Supabase
        .select()
        .order('id');

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NaSpontanie - Wrocław'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.blue[50],
            child: const Text(
              'Wybierz cel misji z bazy danych, aby rozpocząć weryfikację GPS.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),

          // Pobieranie danych z tabeli 'locations' w Supabase
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchLocations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Błąd ładowania danych: ${snapshot.error}'),
                  );
                }

                final locations = snapshot.data ?? [];

                if (locations.isEmpty) {
                  return const Center(
                    child: Text('Brak dostępnych miejsc w bazie Supabase.'),
                  );
                }

                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final loc = locations[index];

                    // Bezpieczne pobieranie wartości z uwzględnieniem kolumny 'title'
                    final String title = loc['title'] ?? 'Nieznane miejsce';
                    final double lat = loc['latitude'] != null
                        ? (loc['latitude'] as num).toDouble()
                        : 0.0;
                    final double lng = loc['longtitude'] != null
                        ? (loc['longtitude'] as num).toDouble()
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Dotknij, aby rozpocząć misję GPS',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.green,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MissionScreen(
                                placeName: title,
                                targetLatitude: lat,
                                targetLongitude: lng,
                              ),
                            ),
                          );
                        },
                      ),
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
