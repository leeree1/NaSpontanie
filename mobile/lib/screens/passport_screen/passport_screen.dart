import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stamps = [
      {'title': 'Rynek', 'unlocked': true},
      {'title': 'Ostrów Tumski', 'unlocked': true},
      {'title': 'Hala Stulecia', 'unlocked': false},
      {'title': 'ZOO Wrocław', 'unlocked': false},
      {'title': 'Sky Tower', 'unlocked': false},
      {'title': 'Hydropolis', 'unlocked': false},
    ];

    return Scaffold(
      appBar: const AppHeader(title: 'Twój Cyfrowy Paszport'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: stamps.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final stamp = stamps[index];
            final unlocked = stamp['unlocked'] as bool;
            return Container(
              decoration: BoxDecoration(
                color: unlocked ? const Color(0xFFE3F2FD) : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked ? const Color(0xFF2196F3) : AppColors.muted,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.verified : Icons.lock,
                    size: 50,
                    color: unlocked ? const Color(0xFF2196F3) : AppColors.muted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stamp['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? AppColors.textPrimary : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    unlocked ? 'Zdobyta!' : 'Zablokowana',
                    style: TextStyle(
                      fontSize: 12,
                      color: unlocked ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
