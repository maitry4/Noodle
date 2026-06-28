import 'dart:math';
import 'package:flutter/material.dart';
import 'package:noodle/core/theme/app_colors.dart';

class SteamLayer extends StatefulWidget {
  final bool active;

  const SteamLayer({super.key, required this.active});

  @override
  State<SteamLayer> createState() => _SteamLayerState();
}

class _SteamLayerState extends State<SteamLayer>
    with SingleTickerProviderStateMixin {
  final List<_Particle> _particles = [];
  final Random _rng = Random();
  late final AnimationController _ctrl;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )
      ..addListener(_onTick)
      ..repeat();
  }

  void _onTick() {
    _tick++;
    if (_tick % 18 == 0 && widget.active) {
      _particles.add(_Particle(_rng));
    }
    for (final p in _particles) {
      p.tick();
    }
    _particles.removeWhere((p) => p.isDead);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SteamPainter(_particles));
  }
}

class _Particle {
  double x, y, opacity, speed, drift;

  _Particle(Random rng)
      : x = 0.3 + rng.nextDouble() * 0.4,
        y = 1.0,
        opacity = 0.0,
        speed = 0.004 + rng.nextDouble() * 0.003,
        drift = (rng.nextDouble() - 0.5) * 0.002;

  void tick() {
    y -= speed;
    x += drift;
    opacity = (y > 0.6 ? (1.0 - y) / 0.4 : y / 0.6).clamp(0.0, 0.35);
  }

  bool get isDead => y < 0.0;
}

class _SteamPainter extends CustomPainter {
  final List<_Particle> particles;
  _SteamPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (final p in particles) {
      paint.color = AppColors.lightBrown.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), 5, paint);
    }
  }

  @override
  bool shouldRepaint(_SteamPainter _) => true;
}