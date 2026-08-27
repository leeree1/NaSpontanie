import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Supabase dla projektu NaSpontanie
  await Supabase.initialize(
    url: 'https://osdyyrltmasukfnilhzy.supabase.co',
    anonKey: 'sb_publishable_Q0-PukTY3_JXl5NqP26EFw_zlHrviEB',
  );

 // Bezpieczna próba logowania anonimowego z blokiem try-catch
  final supabase = Supabase.instance.client;
  if (supabase.auth.currentSession == null) {
    try {
      await supabase.auth.signInAnonymously();
    } catch (e) {
      debugPrint('Logowanie anonimowe wyłączone w Supabase – działamy w trybie publicznym: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NaSpontanie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}