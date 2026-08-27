import 'package:flutter/material.dart';

import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/trip_cost_calculator.dart';
import '../../widgets/app_widgets.dart';
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

  final _durations = ['1h', '2h', '4h', 'Cały dzień'];
  final _transports = ['Pieszo', 'Rower', 'Komunikacja miejska', 'Samochód'];
  final _budgets = [50.0, 100.0, 200.0, 300.0];

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
      final calc = TripCostCalculator.calculateTripPlan(
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
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Planer Wypraw'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Czas trwania wyprawy', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ChoiceChipRow(
              values: _durations,
              selected: _selectedDuration,
              onSelected: (value) => setState(() => _selectedDuration = value),
            ),
            const SizedBox(height: 20),
            const Text('Środek transportu', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ChoiceChipRow(
              values: _transports,
              selected: _selectedTransport,
              onSelected: (value) => setState(() => _selectedTransport = value),
            ),
            const SizedBox(height: 20),
            const Text('Budżet', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ChoiceChipRow<double>(
              values: _budgets,
              selected: _selectedBudget,
              labelBuilder: (budget) => '${budget.toInt()} zł',
              onSelected: (value) => setState(() => _selectedBudget = value),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isLoading
                  ? 'Generowanie trasy...'
                  : 'Wygeneruj spontaniczną trasę',
              icon: Icons.auto_awesome,
              onPressed: _isLoading ? null : _generatePlan,
              isLoading: _isLoading,
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Wybierz parametry i kliknij przycisk,\naby algorytm ułożył dla Ciebie plan!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
