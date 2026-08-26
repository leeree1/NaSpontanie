import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Supabase (tutaj wkleimy Twoje klucze z projektu)
  await Supabase.initialize(
    url: 'https://osdyyrltmasukfnilhzy.supabase.co',
    anonKey: 'sb_publishable_Q0-PukTY3_JXl5NqP26EFw_zlHrviEB',
  );

  runApp(const NaSpontanieApp());
}

class NaSpontanieApp extends StatelessWidget {
  const NaSpontanieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}