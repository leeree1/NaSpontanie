import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../providers/app_provider.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  final LocationService _locationService = LocationService();
  List<LocationModel> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _locationService.getFilteredLocations(
        city: 'Wrocław',
      );
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Błąd ładowania paszportu: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Słuchamy zmian z AppProvider (odblokowane miejsca i XP)
    final appProvider = Provider.of<AppProvider>(context);

    // Sprawdzamy ile miejsc z pobranych jest odblokowanych (klucz to 'location-{id}')
    final unlockedCount = _locations
        .where((loc) => appProvider.isUnlocked('location-${loc.id}'))
        .length;
    
    final progress = _locations.isNotEmpty ? unlockedCount / _locations.length : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppHeader(title: 'Twój Cyfrowy Paszport'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Karta postępu paszportu i XP
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Odznaki Wrocławia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$unlockedCount / ${_locations.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Twoje punkty XP: ${appProvider.userXp} 🌟',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Siatka pieczątek generowana dynamicznie na podstawie prawdziwych danych
                  Expanded(
                    child: _locations.isEmpty
                        ? const Center(child: Text('Brak dostępnych miejsc w paszporcie.'))
                        : GridView.builder(
                            itemCount: _locations.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                            itemBuilder: (context, index) {
                              final location = _locations[index];
                              final uniqueId = 'location-${location.id}';
                              final isUnlocked = appProvider.isUnlocked(uniqueId);

                              return _StampCard(
                                title: location.title,
                                isUnlocked: isUnlocked,
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

class _StampCard extends StatelessWidget {
  const _StampCard({required this.title, required this.isUnlocked});

  final String title;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isUnlocked
                    ? 'Miejsce "$title" zostało już odblokowane! 🌟'
                    : 'Miejsce zablokowane. Odwiedź $title na mapie, aby zdobyć pieczątkę! 🔒',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: isUnlocked ? const Color(0xFF1976D2) : Colors.grey[800],
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnlocked ? const Color(0xFF90CAF9) : Colors.grey.shade300,
              width: isUnlocked ? 2 : 1,
            ),
            boxShadow: [
              if (isUnlocked)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? const Color(0xFFE3F2FD)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    isUnlocked ? Icons.place : Icons.lock_outline,
                    size: 28,
                    color: isUnlocked ? const Color(0xFF1976D2) : Colors.grey.shade400,
                  ),
                  if (isUnlocked)
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? AppColors.textPrimary : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isUnlocked ? 'Zdobyta' : 'Zablokowana',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? const Color(0xFF1976D2) : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}