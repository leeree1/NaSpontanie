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
      color: AppColors.surface.withValues(alpha: 0.94),
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chód',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
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
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.directions_walk,
                    color: AppColors.primary,
                    size: 22,
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
  static const _repeatEvery = Duration(milliseconds: 160);
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
    return GestureDetector(
      onTapDown: (_) => _start(),
      onTapUp: (_) => _stop(),
      onTapCancel: _stop,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(widget.icon, color: AppColors.primaryDark, size: 28),
      ),
    );
  }
}
