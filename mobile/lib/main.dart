import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/app_provider.dart';
import 'screens/auth_screen/auth_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env.example', isOptional: true);
  } catch (_) {}

  await Supabase.initialize(
    url: 'https://osdyyrltmasukfnilhzy.supabase.co',
    publishableKey: 'sb_publishable_Q0-PukTY3_JXl5NqP26EFw_zlHrviEB',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const NaSpontanieApp(),
    ),
  );
}

class NaSpontanieApp extends StatelessWidget {
  const NaSpontanieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthWrapper(),
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
  static const _timeout = Duration(minutes: 30);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      Supabase.instance.client.auth.signOut();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
