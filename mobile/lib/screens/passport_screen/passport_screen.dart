import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../providers/app_provider.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';

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
      final locs = await _locationService.getFilteredLocations(city: 'Wrocław');
      if (mounted) setState(() => _locations = locs);
    } catch (e) {
      debugPrint('Błąd paszportu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final unlockedCount = _locations.where((l) => app.isUnlocked('location-${l.id}')).length;
    final total = _locations.isEmpty ? 1 : _locations.length;
    final progress = unlockedCount / total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cyfrowy Paszport Odkrywcy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppStyles.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.accent, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'PASZPORT MIEJSKI WROCŁAWIA',
                          style: TextStyle(letterSpacing: 2, color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app.rankTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.white24, height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('$unlockedCount / ${_locations.length}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const Text('Stemple', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
                                const Text('Eksploracja', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('${app.userXp}', style: const TextStyle(color: AppColors.xpGold, fontSize: 18, fontWeight: FontWeight.bold)),
                                const Text('XP', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Zdobyte Pieczątki', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _locations.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final spot = _locations[index];
                      final isUnlocked = app.isUnlocked('location-${spot.id}');

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUnlocked ? AppColors.accent : AppColors.cardBorder,
                            width: isUnlocked ? 2 : 1,
                          ),
                          boxShadow: AppStyles.softShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnlocked ? AppColors.accentSoft : AppColors.background,
                                border: Border.all(
                                  color: isUnlocked ? AppColors.accent : Colors.grey.shade300,
                                  style: isUnlocked ? BorderStyle.solid : BorderStyle.none,
                                ),
                              ),
                              child: Icon(
                                isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
                                color: isUnlocked ? AppColors.primaryMid : Colors.grey.shade400,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              spot.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isUnlocked ? AppColors.textDark : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isUnlocked ? 'ODBLOKOWANO' : 'ZABLOKOWANE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? AppColors.primaryMid : Colors.grey.shade400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}