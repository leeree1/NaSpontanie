import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import '../config/maptiler_config.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

class MapPoi {
  const MapPoi({
    required this.id,
    required this.title,
    required this.point,
    this.description,
    this.xp,
  });

  final String id;
  final String title;
  final LatLng point;
  final String? description;
  final int? xp;
}

class MapTilerMap extends StatefulWidget {
  const MapTilerMap({
    super.key,
    this.pois = const [],
    this.userLocation,
    this.initialCenter = const LatLng(51.1097, 17.0325),
    this.initialZoom = 13,
  });

  final List<MapPoi> pois;
  final LatLng? userLocation;
  final LatLng initialCenter;
  final double initialZoom;

  @override
  State<MapTilerMap> createState() => _MapTilerMapState();
}

class _MapTilerMapState extends State<MapTilerMap> {
  static const _pinSize = 40.0;
  static const _userDotSize = 18.0;
  static const _streetZoom = 16.5;

  final MapController _mapController = MapController();
  final TileProvider? _tileProvider =
      kIsWeb ? CancellableNetworkTileProvider() : null;
  var _hasCenteredOnUser = false;
  var _mapReady = false;

  @override
  void didUpdateWidget(MapTilerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLocation != widget.userLocation &&
        widget.userLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToUser());
      return;
    }
    if (oldWidget.pois != widget.pois && widget.userLocation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToPois());
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<MapPoi> get _pois => widget.pois;

  void _onMapReady() {
    _mapReady = true;
    if (widget.userLocation != null) {
      _goToUser();
      return;
    }
    _fitToPois();
  }

  void _goToUser() {
    final location = widget.userLocation;
    if (!mounted || !_mapReady || location == null) return;
    try {
      final zoom = _hasCenteredOnUser
          ? _mapController.camera.zoom
          : _streetZoom;
      _mapController.move(location, zoom);
      _hasCenteredOnUser = true;
    } catch (_) {
      // MapController może nie być jeszcze podpięty do FlutterMap.
    }
  }

  void _fitToPois() {
    if (!mounted || !_mapReady || _pois.isEmpty) return;
    try {
      if (_pois.length == 1) {
        _mapController.move(_pois.first.point, widget.initialZoom);
        return;
      }
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [for (final poi in _pois) poi.point],
          padding: const EdgeInsets.all(56),
          maxZoom: 15,
        ),
      );
    } catch (_) {
      // MapController może nie być jeszcze podpięty do FlutterMap.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MapTilerConfig.apiKey.isEmpty) {
      return const _MapStatus(
        message: 'Nie udało się załadować mapy.',
        details: 'Brak klucza MapTiler.',
        child: Icon(
          Icons.map_outlined,
          size: 48,
          color: AppColors.error,
        ),
      );
    }

    return _buildMap();
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        minZoom: 2,
        maxZoom: 18,
        backgroundColor: const Color(0xFFE8E6D6),
        onMapReady: _onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: MapTilerConfig.rasterTilesUrlTemplate,
          userAgentPackageName: 'com.example.mobile',
          maxNativeZoom: 18,
          keepBuffer: 1,
          panBuffer: 0,
          tileProvider: _tileProvider,
        ),
        if (widget.userLocation != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: widget.userLocation!,
                radius: 22,
                useRadiusInMeter: true,
                color: const Color(0xFF1E88E5).withValues(alpha: 0.18),
                borderColor: const Color(0xFF1E88E5).withValues(alpha: 0.35),
                borderStrokeWidth: 1,
              ),
            ],
          ),
        MarkerLayer(
          alignment: Alignment.topCenter,
          markers: [
            for (final poi in _pois)
              Marker(
                point: poi.point,
                width: _pinSize,
                height: _pinSize,
                alignment: Marker.computePixelAlignment(
                  width: _pinSize,
                  height: _pinSize,
                  left: _pinSize / 2,
                  top: _pinSize * 0.92,
                ),
                child: GestureDetector(
                  onTap: () => _showPoiSheet(poi),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.accent,
                    size: _pinSize,
                  ),
                ),
              ),
          ],
        ),
        if (widget.userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: widget.userLocation!,
                width: _userDotSize,
                height: _userDotSize,
                child: const _UserLocationDot(),
              ),
            ],
          ),
        const RichAttributionWidget(
          alignment: AttributionAlignment.bottomRight,
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
            TextSourceAttribution('MapTiler'),
          ],
        ),
      ],
    );
  }

  void _showPoiSheet(MapPoi poi) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poi.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (poi.description != null && poi.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  poi.description!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              if (poi.xp != null) ...[
                const SizedBox(height: 12),
                XpBadge(xp: poi.xp!),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E88E5),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _MapStatus extends StatelessWidget {
  const _MapStatus({
    required this.message,
    required this.child,
    this.details,
    this.onRetry,
  });

  final Widget child;
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (details != null && details!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  details!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Spróbuj ponownie'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
