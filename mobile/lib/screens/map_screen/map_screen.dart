import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/maptiler_config.dart';
import '../../models/location_model.dart';
import '../../providers/app_provider.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/pulsing_marker.dart';
import 'map_walk_controls.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _fallbackLocation = LatLng(51.1097, 17.0325);
  static const Distance _distanceCalculator = Distance();
  static const double _unlockRadiusMeters = 35.0;

  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  List<LocationModel> _rawLocations = [];
  LatLng _userLocation = _fallbackLocation;
  var _hasWalked = false;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadLocations(),
      _loadUserLocation(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _locationService.getFilteredLocations(city: 'Wrocław');
      if (mounted) {
        setState(() => _rawLocations = locations);
        _checkNearbyPois();
      }
    } catch (e) {
      debugPrint('Błąd pobierania punktów: $e');
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await _locationService.getMyPosition();
      if (!mounted || position == null || _hasWalked) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _checkNearbyPois();
    } catch (_) {}
  }

  void _walk(WalkDirection direction) {
    setState(() {
      _hasWalked = true;
      _userLocation = SimulatedWalk.step(_userLocation, direction);
    });
    _checkNearbyPois();
  }

  void _checkNearbyPois() {
    final app = Provider.of<AppProvider>(context, listen: false);

    for (var loc in _rawLocations) {
      final point = LatLng(loc.latitude, loc.longitude);
      final dist = _distanceCalculator.as(LengthUnit.Meter, _userLocation, point);

      if (dist <= _unlockRadiusMeters) {
        final uid = 'location-${loc.id}';
        if (!app.isUnlocked(uid)) {
          app.unlockLocation(uid, xpReward: loc.xp);
          _showRewardDialog(loc.title, loc.xp);
        }
      }
    }
  }

  void _showRewardDialog(String title, int xp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.xpGold, size: 28),
            SizedBox(width: 8),
            Text('Pieczątka Zdobyta! 🎉', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dotarłeś do punktu:\n"$title"', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.xpGoldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$xp XP zapisano w Twoim Paszporcie!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309), fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Super!'),
          ),
        ],
      ),
    );
  }

  void _showLocationSheet(LocationModel loc) {
    final vibe = _locationService.calculateLiveVibe(loc.id);
    final distanceMeters = _distanceCalculator.as(
      LengthUnit.Meter,
      _userLocation,
      LatLng(loc.latitude, loc.longitude),
    );
    final canCheckIn = distanceMeters <= _unlockRadiusMeters;
    final isUnlocked = Provider.of<AppProvider>(context, listen: false).isUnlocked('location-${loc.id}');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: vibe.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(vibe.icon, size: 14, color: vibe.accentColor),
                        const SizedBox(width: 6),
                        Text(
                          vibe.categoryName,
                          style: TextStyle(color: vibe.accentColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${distanceMeters.toInt()} m stąd',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                loc.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              if (loc.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  loc.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 18),

              // Pasek natężenia ruchu na żywo (Live Occupancy)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ruch w tej chwili: ${vibe.statusText}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        Text(
                          '${vibe.occupancyPercent}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: vibe.accentColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: vibe.occupancyPercent / 100.0,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(vibe.accentColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Zgłoś vibe na żywo (Crowdsourcing)
              const Text(
                'Jak tu teraz jest? Oceń atmosferę:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _vibeVoteButton(ctx, loc.id, 'Spokojnie', '🌿 Luźno', const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _vibeVoteButton(ctx, loc.id, 'W normie', '✨ W sam raz', const Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  _vibeVoteButton(ctx, loc.id, 'Tłok', '🔥 Tłoczno', AppColors.fireOrange),
                ],
              ),
              const SizedBox(height: 18),

              // Przycisk Zamelduj się / Odbierz pieczątkę
              ElevatedButton.icon(
                onPressed: (!isUnlocked && canCheckIn)
                    ? () {
                        Navigator.pop(ctx);
                        final app = Provider.of<AppProvider>(context, listen: false);
                        app.unlockLocation('location-${loc.id}', xpReward: loc.xp);
                        _showRewardDialog(loc.title, loc.xp);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(isUnlocked ? Icons.check_circle_rounded : Icons.place_rounded),
                label: Text(
                  isUnlocked
                      ? 'Miejsce już w Twoim Paszporcie'
                      : (canCheckIn ? 'Zamelduj się (+${loc.xp} XP)' : 'Podejdź bliżej (<35m), aby odebrać XP'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _vibeVoteButton(BuildContext ctx, int locId, String label, String display, Color color) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(color: color.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          _locationService.submitLiveFeedback(locId, label);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dzięki! Oznaczono vibe: $display'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Text(display, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final activeFilter = app.activeMapFilter;

    // Filtrujemy punkty wg wybranego filtra na żywo
    final filteredLocations = _rawLocations.where((loc) {
      if (activeFilter == 'all') return true;
      final vibe = _locationService.calculateLiveVibe(loc.id);
      return vibe.categoryKey == activeFilter;
    }).toList();

    return Scaffold(
      appBar: AppHeader(
        title: 'Radar Live Wrocławia 📡',
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Wycentruj GPS',
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadUserLocation();
              _mapController.move(_userLocation, 16.0);
              setState(() => _isLoading = false);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 15.5,
              minZoom: 2,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: MapTilerConfig.rasterTilesUrlTemplate,
                userAgentPackageName: 'com.example.mobile',
              ),
              // Zasięg czujnika odkrywania wokół użytkownika
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLocation,
                    radius: _unlockRadiusMeters,
                    useRadiusInMeter: true,
                    color: AppColors.accent.withOpacity(0.18),
                    borderColor: AppColors.accent.withOpacity(0.55),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
              // Pulsujące markery radarowe
              MarkerLayer(
                markers: [
                  for (final loc in filteredLocations)
                    Marker(
                      point: LatLng(loc.latitude, loc.longitude),
                      width: 70,
                      height: 70,
                      child: Builder(
                        builder: (context) {
                          final vibe = _locationService.calculateLiveVibe(loc.id);
                          return PulsingLiveMarker(
                            color: vibe.accentColor,
                            icon: vibe.icon,
                            badgeText: '${vibe.occupancyPercent}%',
                            isHot: vibe.isHot,
                            onTap: () => _showLocationSheet(loc),
                          );
                        },
                      ),
                    ),
                  // Kropka pozycji użytkownika
                  Marker(
                    point: _userLocation,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E88E5),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Pasek filtrów radaru
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Wszystko', 'all', app),
                  const SizedBox(width: 8),
                  _filterChip('✨ Perełki', 'gems', app),
                  const SizedBox(width: 8),
                  _filterChip('☕ Chill & Kawa', 'chill', app),
                  const SizedBox(width: 8),
                  _filterChip('🏛️ Mosty & Kultura', 'sights', app),
                  const SizedBox(width: 8),
                  _filterChip('🔥 Wrocław Nocą', 'night', app),
                ],
              ),
            ),
          ),

          // Pad do symulacji spaceru
          Positioned(
            left: 16,
            bottom: 24,
            child: MapWalkPad(onStep: _walk),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String key, AppProvider app) {
    final isSelected = app.activeMapFilter == key;
    return GestureDetector(
      onTap: () => app.setMapFilter(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
          boxShadow: AppStyles.softShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}