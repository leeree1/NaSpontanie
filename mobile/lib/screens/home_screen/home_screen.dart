import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final Function(String categoryKey)? onSelectCategory;
  final VoidCallback? onOpenMap;

  const HomeScreen({
    super.key,
    this.onSelectCategory,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pasek powitania i seria dni
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wrocław Live Radar 📍',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            app.rankTitle,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppStyles.softShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: AppColors.xpGold, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${app.userXp} XP',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Live Ticker: Co dzieje się teraz w mieście
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppStyles.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'WROCŁAW TERAZ NA ŻYWO',
                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sprawdź, gdzie tętni życie, a gdzie zjesz w ciszy!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: onOpenMap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('Otwórz Pełną Mapę Ruchu', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Sekcja 4 Trybów Odkrywania Live
              const Row(
                children: [
                  Text(
                    'Tryby Odkrywania Live',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.sensors, size: 18, color: AppColors.primaryMid),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Wybierz filtr, aby zobaczyć gorące strefy lub cichy chillout:',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),

              // 4 Tryby przekierowujące na mapę
              _buildLiveCategoryCard(
                title: 'Ukryte Perełki ✨',
                subtitle: 'Sekretne podwórka i kameralne zakątki z dala od tłumów.',
                badgeText: 'Niski ruch',
                badgeColor: const Color(0xFF10B981),
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFF6366F1),
                onTap: () => onSelectCategory?.call('gems'),
              ),
              const SizedBox(height: 12),

              _buildLiveCategoryCard(
                title: 'Kawa i Chill ☕',
                subtitle: 'Miejsca, gdzie zjesz w spokoju, popracujesz lub odpoczniesz.',
                badgeText: 'Strefa relaksu',
                badgeColor: const Color(0xFF0284C7),
                icon: Icons.coffee_rounded,
                iconColor: const Color(0xFFEC4899),
                onTap: () => onSelectCategory?.call('chill'),
              ),
              const SizedBox(height: 12),

              _buildLiveCategoryCard(
                title: 'Zabytki i Mosty 🏛️',
                subtitle: 'Ikony miasta, Ostrów Tumski, legendy i punkty widokowe.',
                badgeText: 'Kultura & Widoki',
                badgeColor: const Color(0xFF8B5CF6),
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF0F766E),
                onTap: () => onSelectCategory?.call('sights'),
              ),
              const SizedBox(height: 12),

              _buildLiveCategoryCard(
                title: 'Wrocław Nocą 🔥',
                subtitle: 'Największe skupiska ludzi, tętniące puby, neony i wydarzenia.',
                badgeText: 'GORĄCY RUCH 🔥',
                badgeColor: AppColors.fireOrange,
                icon: Icons.nightlife_rounded,
                iconColor: const Color(0xFFF59E0B),
                onTap: () => onSelectCategory?.call('night'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCategoryCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppStyles.softShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.cardBorder),
            ],
          ),
        ),
      ),
    );
  }
}