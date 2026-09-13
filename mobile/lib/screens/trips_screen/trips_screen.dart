import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../providers/app_provider.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final LocationService _locationService = LocationService();

  String _selectedTransport = 'Pieszo';
  int _selectedHours = 2;
  double _selectedBudget = 30.0;
  bool _isLoading = false;
  List<LocationModel> _generatedRoute = [];

  final List<String> _transportOptions = ['Pieszo', 'Rower / Hulajnoga', 'MPK Wrocław'];
  final List<int> _hourOptions = [1, 2, 3, 5];
  final List<double> _budgetOptions = [0.0, 20.0, 50.0, 100.0];

  Future<void> _generateSpontaneousTrip() async {
    setState(() => _isLoading = true);
    try {
      final stopsCount = _selectedHours <= 1 ? 2 : (_selectedHours <= 3 ? 3 : 5);

      final locations = await _locationService.getRandomTripLocations(
        stopsCount,
        city: 'Wrocław',
        transportType: _selectedTransport,
        maxBudget: _selectedBudget,
        maxTimeMinutes: _selectedHours * 60,
      );

      setState(() {
        _generatedRoute = locations;
      });

      if (mounted && locations.isNotEmpty) {
        Provider.of<AppProvider>(context, listen: false).setActiveTrip(locations);
      }
    } catch (e) {
      debugPrint('Błąd generatora: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Spontaniczny Planer (#14)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dopasuj parametry wypadku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Środek transportu:', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _transportOptions.map((mode) {
                      final active = _selectedTransport == mode;
                      return ChoiceChip(
                        label: Text(mode),
                        selected: active,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(color: active ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                        onSelected: (val) => setState(() => _selectedTransport = mode),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dostępny czas:', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                      Text('$_selectedHours godz.', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryMid)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _hourOptions.map((h) {
                      final active = _selectedHours == h;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: active ? AppColors.accentSoft : Colors.white,
                              side: BorderSide(color: active ? AppColors.accent : AppColors.cardBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => setState(() => _selectedHours = h),
                            child: Text('${h}h', style: TextStyle(color: active ? AppColors.primaryMid : AppColors.textDark, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Maksymalny budżet:', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                      Text('${_selectedBudget.toInt()} PLN', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryMid)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _budgetOptions.map((b) {
                      final active = _selectedBudget == b;
                      return ChoiceChip(
                        label: Text(b == 0.0 ? 'Za free' : '${b.toInt()} zł'),
                        selected: active,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(color: active ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                        onSelected: (val) => setState(() => _selectedBudget = b),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateSpontaneousTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isLoading ? 'Dopasowywanie bazy Supabase...' : 'Wygeneruj Trasę Spontaniczną'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_generatedRoute.isNotEmpty) ...[
              const Text('Harmonogram Twojej Wyprawy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _generatedRoute.length,
                itemBuilder: (context, index) {
                  final spot = _generatedRoute[index];
                  final isLast = index == _generatedRoute.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 60,
                              color: AppColors.accent,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: AppStyles.softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      spot.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.xpGoldSoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+${spot.xp} XP',
                                      style: const TextStyle(color: AppColors.xpGold, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              if (spot.description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  spot.description,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}