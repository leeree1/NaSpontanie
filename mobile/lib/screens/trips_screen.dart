import 'package:flutter/material.dart';
import 'trip_flow_screens.dart'; // Importujemy plik z nowymi ekranami

class TripsScreen extends StatefulWidget {
  const TripsScreen({Key? key}) : super(key: key);

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  // Stan formularza parametrów podróży
  String _selectedTransport = 'Pieszo';
  double _budget = 50.0;
  double _hours = 4.0;
  final TextEditingController _startLocationController =
      TextEditingController(text: 'Wrocław, Rynek');

  final List<String> _transportOptions = [
    'Pieszo',
    'Rower',
    'Komunikacja miejska',
    'Samochód'
  ];

  @override
  void dispose() {
    _startLocationController.dispose();
    super.dispose();
  }

  void _generatePlan() {
    // Przechodzimy bezpośrednio do ekranu ładowania trasy,
    // przekazując dane wpisane przez użytkownika w formularzu!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratingTripScreen(
          startLocation: _startLocationController.text,
          hours: _hours,
          budget: _budget,
          transport: _selectedTransport,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Wypraw'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Zaplanuj swoją mikro-przygodę',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Określ swoje ograniczenia (czas, budżet i start), a system dopasuje dla Ciebie idealny plan dnia.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Miejsce startu
            TextField(
              controller: _startLocationController,
              decoration: InputDecoration(
                labelText: 'Miejsce startu',
                prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Dostępny czas (godziny)
            Text(
              'Dostępny czas: ${_hours.toStringAsFixed(0)} h',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _hours,
              min: 1,
              max: 12,
              divisions: 11,
              activeColor: Colors.green[700],
              label: '${_hours.toStringAsFixed(0)} h',
              onChanged: (value) {
                setState(() {
                  _hours = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // Budżet (PLN)
            Text(
              'Budżet: ${_budget.toStringAsFixed(0)} PLN',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _budget,
              min: 0,
              max: 300,
              divisions: 30,
              activeColor: Colors.green[700],
              label: '${_budget.toStringAsFixed(0)} PLN',
              onChanged: (value) {
                setState(() {
                  _budget = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Środek transportu
            const Text(
              'Środek transportu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _transportOptions.map((transport) {
                bool isSelected = _selectedTransport == transport;
                return ChoiceChip(
                  label: Text(transport),
                  selected: isSelected,
                  selectedColor: Colors.green[100],
                  onSelected: (selected) {
                    setState(() {
                      _selectedTransport = transport;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Przycisk generowania planu
            ElevatedButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.explore),
              label: const Text('Znajdź plan podróży'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}