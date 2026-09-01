import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_theme.dart';

enum WalkDirection { north, south, east, west }

/// Przesuwa punkt o stały krok w metrach — do testowego „chodzenia” po mapie.
class SimulatedWalk {
  const SimulatedWalk._();

  static const Distance _distance = Distance();
  static const double stepMeters = 18;

  static LatLng step(
    LatLng from,
    WalkDirection direction, {
    double meters = stepMeters,
  }) {
    final heading = switch (direction) {
      WalkDirection.north => 0.0,
      WalkDirection.east => 90.0,
      WalkDirection.south => 180.0,
      WalkDirection.west => 270.0,
    };
    return _distance.offset(from, meters, heading);
  }
}

class MapWalkPad extends StatelessWidget {
  const MapWalkPad({super.key, required this.onStep});

  final ValueChanged<WalkDirection> onStep;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withOpacity(0.95),
      elevation: 6,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.directions_walk, color: AppColors.primary, size: 16),
                SizedBox(width: 4),
                Text(
                  'Symulator Ruchu',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _WalkButton(
              icon: Icons.keyboard_arrow_up,
              onStep: () => onStep(WalkDirection.north),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WalkButton(
                  icon: Icons.keyboard_arrow_left,
                  onStep: () => onStep(WalkDirection.west),
                ),
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.navigation,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                ),
                _WalkButton(
                  icon: Icons.keyboard_arrow_right,
                  onStep: () => onStep(WalkDirection.east),
                ),
              ],
            ),
            _WalkButton(
              icon: Icons.keyboard_arrow_down,
              onStep: () => onStep(WalkDirection.south),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkButton extends StatefulWidget {
  const _WalkButton({required this.icon, required this.onStep});

  final IconData icon;
  final VoidCallback onStep;

  @override
  State<_WalkButton> createState() => _WalkButtonState();
}

class _WalkButtonState extends State<_WalkButton> {
  static const _repeatEvery = Duration(milliseconds: 150);
  Timer? _repeatTimer;

  void _start() {
    widget.onStep();
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(_repeatEvery, (_) => widget.onStep());
  }

  void _stop() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _stop(),
        onTapCancel: _stop,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(widget.icon, color: AppColors.primaryDark, size: 28),
        ),
      ),
    );
  }
}