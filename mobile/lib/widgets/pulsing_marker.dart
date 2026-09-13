import 'package:flutter/material.dart';

class PulsingLiveMarker extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String badgeText;
  final bool isHot;
  final VoidCallback onTap;

  const PulsingLiveMarker({
    super.key,
    required this.color,
    required this.icon,
    required this.badgeText,
    this.isHot = false,
    required this.onTap,
  });

  @override
  State<PulsingLiveMarker> createState() => _PulsingLiveMarkerState();
}

class _PulsingLiveMarkerState extends State<PulsingLiveMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isHot ? 1200 : 2000),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Rozchodzący się pierścień radaru
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 28 + (_animation.value * 32),
                height: 28 + (_animation.value * 32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity((1.0 - _animation.value) * 0.45),
                ),
              );
            },
          ),
          // Centralna świecąca szpilka
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.55),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(widget.icon, size: 17, color: Colors.white),
          ),
          // Dynamiczny dymek z informacją o ruchu nad punktem
          Positioned(
            top: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}