import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({Key? key}) : super(key: key);

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final LocationService _locationService = LocationService();
  
  bool _isLoading = false;
  List<LocationModel> _plannedTrip = [];
  
  String _selectedDuration = '2h';
  String _selectedTransport = 'Pieszo';

  final List<String> _durations = ['1h', '2h', '4h', 'Cały dzień'];
  final List<String> _transports = ['Pieszo', 'Rower', 'Komunikacja miejska', 'Samochód'];

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);
    try {
      // Pobieramy listę lokacji jako LocationModel
      List<LocationModel> fetchedLocations = await _locationService.getFilteredLocations(city: 'Wrocław');
      
      // Prosty algorytm losujący/wybierający cele do planu trasy
      fetchedLocations.shuffle();
      
      int countToTake = _selectedDuration == '1h' ? 1 : (_selectedDuration == '2h' ? 2 : 3);
      if (countToTake > fetchedLocations.length) {
        countToTake = fetchedLocations.length;
      }

      setState(() {
        _plannedTrip = fetchedLocations.take(countToTake).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas generowania planu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Planer Wypraw', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Czas trwania wyprawy',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _durations.length,
                itemBuilder: (context, index) {
                  final duration = _durations[index];
                  final isSelected = _selectedDuration == duration;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(duration),
                      selected: isSelected,
                      selectedColor: Colors.green[700],
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDuration = duration);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Środek transportu',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _transports.length,
                itemBuilder: (context, index) {
                  final transport = _transports[index];
                  final isSelected = _selectedTransport == transport;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(transport),
                      selected: isSelected,
                      selectedColor: Colors.green[700],
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedTransport = transport);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generatePlan,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Generowanie trasy...' : 'Wygeneruj spontaniczną trasę'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Twoja spersonalizowana trasa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _plannedTrip.isEmpty
                      ? const Center(
                          child: Text(
                            'Wybierz parametry i kliknij przycisk,\naby algorytm ułożył dla Ciebie plan!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _plannedTrip.length,
                          itemBuilder: (context, index) {
                            final loc = _plannedTrip[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green[50],
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          loc.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '+${loc.xp} XP',
                                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}