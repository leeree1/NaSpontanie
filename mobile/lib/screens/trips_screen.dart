import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'trip_calculator.dart';
import 'trip_flow_screens.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final LocationService _locationService = LocationService();

  bool _isLoading = false;

  String _selectedDuration = '2h';
  String _selectedTransport = 'Pieszo';
  double _selectedBudget = 100;

  final List<String> _durations = ['1h', '2h', '4h', 'Cały dzień'];
  final List<String> _transports = [
    'Pieszo',
    'Rower',
    'Komunikacja miejska',
    'Samochód',
  ];
  final List<double> _budgets = [50, 100, 200, 300];

  double _hoursFromDuration(String duration) {
    switch (duration) {
      case '1h':
        return 1;
      case '2h':
        return 2;
      case '4h':
        return 4;
      default:
        return 8;
    }
  }

  int _locationCount(String duration) {
    switch (duration) {
      case '1h':
        return 1;
      case '2h':
        return 2;
      case '4h':
        return 3;
      default:
        return 4;
    }
  }

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);
    try {
      final fetchedLocations = await _locationService.getFilteredLocations(
        city: 'Wrocław',
      );
      if (!mounted) return;

      if (fetchedLocations.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Brak dostępnych punktów do trasy.')),
        );
        return;
      }

      fetchedLocations.shuffle();
      var countToTake = _locationCount(_selectedDuration);
      if (countToTake > fetchedLocations.length) {
        countToTake = fetchedLocations.length;
      }

      final selected = fetchedLocations.take(countToTake).toList();
      final hours = _hoursFromDuration(_selectedDuration);
      final calc = TripCalculator.calculateTripPlan(
        availableHours: hours,
        userBudget: _selectedBudget,
        transportType: _selectedTransport,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratingTripScreen(
            startLocation: 'Wrocław',
            hours: hours,
            budget: _selectedBudget,
            transport: _selectedTransport,
            calculatedCost: calc['estimatedCost'] as double,
            locations: selected.map((loc) => loc.toJson()).toList(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas generowania planu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Planer Wypraw',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _ChipRow(
              values: _durations,
              selected: _selectedDuration,
              onSelected: (value) => setState(() => _selectedDuration = value),
            ),
            const SizedBox(height: 20),
            const Text(
              'Środek transportu',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _ChipRow(
              values: _transports,
              selected: _selectedTransport,
              onSelected: (value) => setState(() => _selectedTransport = value),
            ),
            const SizedBox(height: 20),
            const Text(
              'Budżet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _budgets.length,
                itemBuilder: (context, index) {
                  final budget = _budgets[index];
                  final isSelected = _selectedBudget == budget;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${budget.toInt()} zł'),
                      selected: isSelected,
                      selectedColor: Colors.green[700],
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedBudget = budget);
                        }
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
                label: Text(
                  _isLoading
                      ? 'Generowanie trasy...'
                      : 'Wygeneruj spontaniczną trasę',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Wybierz parametry i kliknij przycisk,\naby algorytm ułożył dla Ciebie plan!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          final isSelected = selected == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(value),
              selected: isSelected,
              selectedColor: Colors.green[700],
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) onSelected(value);
              },
            ),
          );
        },
      ),
    );
  }
}
