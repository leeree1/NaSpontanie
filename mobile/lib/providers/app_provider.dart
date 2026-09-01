import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  int _userXp = 1250;
  bool _isLoading = false;
  
  // Przechowuje ID odblokowanych miejsc (Cyfrowy Paszport)
  final Set<String> _unlockedLocationIds = {};

  int get userXp => _userXp;
  bool get isLoading => _isLoading;
  Set<String> get unlockedLocationIds => _unlockedLocationIds;

  // Metoda dodająca punkty XP
  void addXp(int amount) {
    _userXp += amount;
    notifyListeners();
  }

  // Odblokowuje miejsce na mapie i opcjonalnie daje XP za odkrycie
  void unlockLocation(String id, {int xpReward = 100}) {
    if (!_unlockedLocationIds.contains(id)) {
      _unlockedLocationIds.add(id);
      _userXp += xpReward; // Dodajemy XP za odkrycie nowego miejsca!
      notifyListeners();
    }
  }

  // Sprawdza czy dane miejsce jest już odblokowane
  bool isUnlocked(String id) => _unlockedLocationIds.contains(id);

  // Sprawdzanie czy użytkownik jest zalogowany
  bool get isAuthenticated => _client.auth.currentUser != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}