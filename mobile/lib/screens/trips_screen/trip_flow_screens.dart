import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class GeneratingTripScreen extends StatefulWidget {
  const GeneratingTripScreen({
    super.key,
    required this.startLocation,
    required this.hours,
    required this.budget,
    required this.transport,
    required this.calculatedCost,
    required this.locations,
  });

  final String startLocation;
  final double hours;
  final double budget;
  final String transport;
  final double calculatedCost;
  final List<Map<String, dynamic>> locations;

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
              calculatedCost: widget.calculatedCost,
              locations: widget.locations,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Generowanie trasy...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Dopasowujemy punkty i przeliczamy budżet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class TripProposalScreen extends StatelessWidget {
  const TripProposalScreen({
    super.key,
    required this.startLocation,
    required this.hours,
    required this.budget,
    required this.transport,
    required this.calculatedCost,
    required this.locations,
  });

  final String startLocation;
  final double hours;
  final double budget;
  final String transport;
  final double calculatedCost;
  final List<Map<String, dynamic>> locations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propozycja Trasy')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Szczegóły wygenerowanej wyprawy',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    Text('• Start: $startLocation'),
                    const SizedBox(height: 6),
                    Text('• Czas: ${hours.toInt()} h | Transport: $transport'),
                    const SizedBox(height: 6),
                    Text('• Twój budżet: ${budget.toInt()} PLN'),
                    const SizedBox(height: 6),
                    Text(
                      '• Szacowany koszt: ${calculatedCost.toStringAsFixed(2)} PLN',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('• Punkty na trasie: ${locations.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Punkty trasy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  final title = loc['title']?.toString() ?? 'Punkt ${index + 1}';
                  final xp = loc['location_xp'];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(title),
                    trailing: xp != null ? XpBadge(xp: int.tryParse('$xp') ?? 0) : null,
                  );
                },
              ),
            ),
            AppButton(
              label: 'Rozpocznij trasę',
              icon: Icons.play_arrow,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveTripScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Edytuj parametry',
              outlined: true,
              onPressed: () => Navigator.pop(context),
            ),
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
                      calculatedCost: calculatedCost,
                      locations: locations,
                    ),
                  ),
                );
              },
              child: const Text('Wygeneruj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveTripScreen extends StatelessWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasa w toku'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 80, color: AppColors.primary),
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
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            AppButton(
              label: 'Zakończ trasę',
              color: AppColors.error,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TripSummaryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podsumowanie Wyprawy'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, size: 90, color: AppColors.secondary),
            const SizedBox(height: 20),
            const Text(
              'Gratulacje! Trasa ukończona',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Zdobyto +200 XP oraz nową pieczątkę w paszporcie!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            AppButton(
              label: 'Zakończ i wróć do głównego menu',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
