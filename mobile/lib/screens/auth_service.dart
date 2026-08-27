import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUp(String email, String password, String username) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    if (response.user == null) {
      throw Exception('Rejestracja nieudana');
    }

    await _client.from('profiles').insert({
      'id': response.user!.id,
      'username': username,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signIn(String email, String password) async {
    final response = await _client.auth.signIn(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Logowanie nieudane');
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
    await _client.auth.resetPasswordForEmail(email);
  }
}
