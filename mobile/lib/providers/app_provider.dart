import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  int _userXp = 1250;
  bool _isLoading = false;

  int get userXp => _userXp;
  bool get isLoading => _isLoading;

  // Przykładowa metoda dodająca punkty XP po ukończeniu misji
  void addXp(int amount) {
    _userXp += amount;
    notifyListeners();
  }

  // Sprawdzanie czy użytkownik jest zalogowany
  bool get isAuthenticated => _client.auth.currentUser != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}