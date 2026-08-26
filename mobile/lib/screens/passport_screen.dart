import 'package:flutter/material.dart';

class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stamps = [
      {'title': 'Rynek', 'unlocked': true},
      {'title': 'Ostrów Tumski', 'unlocked': true},
      {'title': 'Hala Stulecia', 'unlocked': false},
      {'title': 'ZOO Wrocław', 'unlocked': false},
      {'title': 'Sky Tower', 'unlocked': false},
      {'title': 'Hydropolis', 'unlocked': false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Twój Cyfrowy Paszport')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: stamps.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final stamp = stamps[index];
            final bool isUnlocked = stamp['unlocked'];

            return Container(
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.blue.shade50 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked ? Colors.blue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUnlocked ? Icons.verified : Icons.lock,
                    size: 50,
                    color: isUnlocked ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stamp['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isUnlocked ? 'Zdobyta!' : 'Zablokowana',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnlocked ? Colors.green.shade700 : Colors.grey.shade600,
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