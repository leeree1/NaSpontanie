import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mission_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showMuseums = false;

  Widget _categoryButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      elevation: selected ? 1.5 : 0,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? Colors.green[700] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.green[700] : Colors.grey[700],
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchLocations() async {
    final response = await Supabase.instance.client
        .from('locations')
        .select()
        .order('id');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> _fetchMuseums() async {
    final response = await Supabase.instance.client
        .from('museums_import')
        .select()
        .not('latitude', 'is', null)
        .not('longtitude', 'is', null)
        .order('title');

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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: _categoryButton(
                    label: 'Miejsca',
                    icon: Icons.place_outlined,
                    selected: !showMuseums,
                    onTap: () {
                      setState(() {
                        showMuseums = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _categoryButton(
                    label: 'Muzea',
                    icon: Icons.museum_outlined,
                    selected: showMuseums,
                    onTap: () {
                      setState(() {
                        showMuseums = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: showMuseums ? _fetchMuseums() : _fetchLocations(),
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
                  return Center(
                    child: Text(
                      showMuseums
                          ? 'Brak muzeów z uzupełnioną lokalizacją GPS'
                          : 'Brak dostępnych miejsc w bazie Supabase',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final loc = locations[index];

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
