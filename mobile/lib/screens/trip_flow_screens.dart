import 'package:flutter/material.dart';
import 'main_screen.dart';

// --- 1. EKRAN ŁADOWANIA ---
class GeneratingTripScreen extends StatefulWidget {
  final String startLocation;
  final double hours;
  final double budget;
  final String transport;

  const GeneratingTripScreen({
    Key? key,
    required this.startLocation,
    required this.hours,
    required this.budget,
    required this.transport,
  }) : super(key: key);

  @override
  State<GeneratingTripScreen> createState() => _GeneratingTripScreenState();
}

class _GeneratingTripScreenState extends State<GeneratingTripScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripProposalScreen(
              startLocation: widget.startLocation,
              hours: widget.hours,
              budget: widget.budget,
              transport: widget.transport,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Generowanie trasy...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 8),
            Text(
              'Dopasowujemy najlepsze punkty do Twoich kryteriów.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. EKRAN PROPOZYCJI TRASY (Odbiera parametry z formularza) ---
class TripProposalScreen extends StatelessWidget {
  final String startLocation;
  final double hours;
  final double budget;
  final String transport;

  const TripProposalScreen({
    Key? key,
    required this.startLocation,
    required this.hours,
    required this.budget,
    required this.transport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propozycja Trasy'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Twój spersonalizowany plan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    Text('• Miejsce startu: $startLocation'),
                    const SizedBox(height: 6),
                    Text('• Dostępny czas: ${hours.toInt()} h'),
                    const SizedBox(height: 6),
                    Text('• Budżet: ${budget.toInt()} PLN'),
                    const SizedBox(height: 6),
                    Text('• Transport: $transport'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveTripScreen()),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Rozpocznij trasę'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context); // Powrót do formularza
              },
              child: const Text('Edytuj parametry'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeneratingTripScreen(
                      startLocation: startLocation,
                      hours: hours,
                      budget: budget,
                      transport: transport,
                    ),
                  ),
                );
              },
              child: const Text('Wygeneruj ponownie', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. EKRAN AKTYWNEJ TRASY ---
class ActiveTripScreen extends StatelessWidget {
  const ActiveTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasa w toku'),
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Poruszasz się wyznaczoną trasą!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Udaj się do punktu kontrolnego i zweryfikuj obecność.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TripSummaryScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Zakończ trasę', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. EKRAN PODSUMOWANIA ---
class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podsumowanie Wyprawy'),
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, size: 90, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'Gratulacje! Trasa ukończona',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Zdobyto +200 XP oraz nową pieczątkę w paszporcie!',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Zakończ i wróć do głównego menu', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}