import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Supabase dla projektu NaSpontanie
  await Supabase.initialize(
    url: 'https://osdyyrltmasukfnilhzy.supabase.co',
    publishableKey: 'sb_publishable_Q0-PukTY3_JXl5NqP26EFw_zlHrviEB',
  );

  runApp(const NaSpontanieApp());
}

class NaSpontanieApp extends StatelessWidget {
  const NaSpontanieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        return session == null
            ? const AuthScreen()
            : const _SessionTimeout(child: MainScreen());
      },
    );
  }
}

class _SessionTimeout extends StatefulWidget {
  const _SessionTimeout({required this.child});

  final Widget child;

  @override
  State<_SessionTimeout> createState() => _SessionTimeoutState();
}

class _SessionTimeoutState extends State<_SessionTimeout> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(minutes: 30), () {
      Supabase.instance.client.auth.signOut();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
