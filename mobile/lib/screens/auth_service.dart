import 'package:supabase_flutter/supabase_flutter.dart';
import 'security_service.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  static final List<DateTime> _failedAttempts = [];

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? validateEmail(String value) {
    final trimmed = value.trim();
    final email = SecurityService.sanitizeInput(trimmed).toLowerCase();
    return email == trimmed.toLowerCase() && _emailPattern.hasMatch(email)
        ? null
        : 'Podaj poprawny email';
  }

  static String? validatePassword(String value) {
    return SecurityService.isStrongPassword(value)
        ? null
        : 'Hasło: min. 8 znaków, wielka i mała litera, cyfra oraz znak specjalny';
  }

  static String? validateUsername(String value) {
    final trimmed = value.trim();
    final username = SecurityService.sanitizeInput(trimmed);
    return username == trimmed &&
            RegExp(r'^[a-zA-Z0-9_.-]{3,30}$').hasMatch(username)
        ? null
        : 'Nazwa: 3-30 znaków (litery, cyfry, _, . lub -)';
  }

  bool _rateLimitExceeded() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 1));
    _failedAttempts.removeWhere((attempt) => attempt.isBefore(cutoff));
    return _failedAttempts.length >= 5;
  }

  Future<void> _recordFailedAttempt(String email) async {
    _failedAttempts.add(DateTime.now());
    try {
      await _client.rpc('log_auth_failure', params: {'attempt_email': email});
    } catch (_) {
      // Logging must never reveal whether an account exists.
    }
  }

  Future<AuthResponse> signUp(
    String email,
    String password,
    String username,
  ) async {
    final cleanEmail = SecurityService.sanitizeInput(email).toLowerCase();
    final cleanUsername = SecurityService.sanitizeInput(username);
    if (validateEmail(cleanEmail) != null ||
        validatePassword(password) != null ||
        validateUsername(cleanUsername) != null) {
      throw const AuthException('Dane rejestracji są nieprawidłowe.');
    }

    final response = await _client.auth.signUp(
      email: cleanEmail,
      password: password,
      data: {'username': cleanUsername},
    );

    if (response.user == null) {
      throw const AuthException('Rejestracja nieudana.');
    }
    return response;
  }

  Future<void> signIn(String email, String password) async {
    final cleanEmail = SecurityService.sanitizeInput(email).toLowerCase();
    if (validateEmail(cleanEmail) != null || password.isEmpty) {
      throw const AuthException('Nieprawidłowy email lub hasło.');
    }
    if (_rateLimitExceeded()) {
      throw const AuthException('Zbyt wiele prób. Spróbuj ponownie za minutę.');
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Nieprawidłowy email lub hasło.');
      }
    } catch (_) {
      await _recordFailedAttempt(cleanEmail);
      rethrow;
    }
  }

  //logout tutaj
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // resetowanie hasla
  Future<void> resetPassword(String email) async {
    final cleanEmail = SecurityService.sanitizeInput(email).toLowerCase();
    if (validateEmail(cleanEmail) != null) {
      throw const AuthException('Podaj poprawny email.');
    }
    await _client.auth.resetPasswordForEmail(cleanEmail);
  }
}
