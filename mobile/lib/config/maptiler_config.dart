import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapTilerConfig {
  const MapTilerConfig._();

  static const sourceId = 'maptiler_planet';
  static const styleUri =
      'https://api.maptiler.com/maps/basic-v2/style.json?key={key}';

  static String get apiKey {
    const fromDefine = String.fromEnvironment('MAPTILER_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      return dotenv.env['MAPTILER_API_KEY']?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get tilesJsonUrl =>
      'https://api.maptiler.com/tiles/v3/tiles.json?key=$apiKey';

  static String get vectorTilesUrlTemplate =>
      'https://api.maptiler.com/tiles/v3/{z}/{x}/{y}.pbf?key=$apiKey';

  static String get rasterTilesUrlTemplate =>
      'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=$apiKey';
}
