import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  int _userXp = 1450;
  int _streakDays = 3;
  bool _isLoading = false;
  final Set<String> _unlockedLocationIds = {'location-1', 'location-3'};

  // Aktywny filtr radaru na mapie
  String _activeMapFilter = 'all';

  int get userXp => _userXp;
  int get streakDays => _streakDays;
  bool get isLoading => _isLoading;
  Set<String> get unlockedLocationIds => _unlockedLocationIds;
  String get activeMapFilter => _activeMapFilter;

  int get currentLevel => (_userXp / 500).floor() + 1;
  int get xpInCurrentLevel => _userXp % 500;
  double get levelProgress => xpInCurrentLevel / 500.0;

  String get rankTitle {
    if (currentLevel == 1) return 'Początkujący Włóczykij';
    if (currentLevel == 2) return 'Tropiciel Zaułków';
    if (currentLevel == 3) return 'Wrocławski Flâneur';
    if (currentLevel == 4) return 'Mistrz Legend i Mostów';
    return 'Gubernator Nadodrza';
  }

  void setMapFilter(String filterKey) {
    _activeMapFilter = filterKey;
    notifyListeners();
  }

  void addXp(int amount) {
    _userXp += amount;
    notifyListeners();
  }

  void unlockLocation(String id, {int xpReward = 150}) {
    if (!_unlockedLocationIds.contains(id)) {
      _unlockedLocationIds.add(id);
      _userXp += xpReward;
      notifyListeners();
    }
  }

  bool isUnlocked(String id) => _unlockedLocationIds.contains(id);

  bool get isAuthenticated => _client.auth.currentUser != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}