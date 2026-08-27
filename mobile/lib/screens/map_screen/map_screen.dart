import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Mapa — ekran tymczasowy'),
          ],
        ),
      ),
    );
  }
}
