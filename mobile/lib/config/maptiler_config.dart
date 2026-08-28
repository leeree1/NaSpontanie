import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapTilerConfig {
  const MapTilerConfig._();

  static const sourceId = 'maptiler_planet';
  static const styleUri =
      'https://api.maptiler.com/maps/basic-v2/style.json?key={key}';

  /// Tymczasowy fallback, żeby mapa działała bez `.env` u innych osób.
  /// `.env` jest w `.gitignore` i Flutter ładuje go tylko jako asset przy
  /// pełnym restarcie (`flutter run`), nie po hot reload.
  static const _fallbackApiKey = '2aRjlcYxiDk0tGr1tDIM';

  static String get apiKey {
    const fromDefine = String.fromEnvironment('MAPTILER_API_KEY');
    if (_isUsable(fromDefine)) return fromDefine.trim();

    try {
      final fromEnv = dotenv.env['MAPTILER_API_KEY']?.trim() ?? '';
      if (_isUsable(fromEnv)) return fromEnv;
    } catch (_) {
      // dotenv może nie być załadowany — użyj fallbacku.
    }

    return _fallbackApiKey;
  }

  static bool _isUsable(String value) {
    final key = value.trim();
    if (key.isEmpty) return false;
    if (key.startsWith('your_')) return false;
    return true;
  }

  static String get tilesJsonUrl =>
      'https://api.maptiler.com/tiles/v3/tiles.json?key=$apiKey';

  static String get vectorTilesUrlTemplate =>
      'https://api.maptiler.com/tiles/v3/{z}/{x}/{y}.pbf?key=$apiKey';

  static String get rasterTilesUrlTemplate =>
      'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=$apiKey';
}
