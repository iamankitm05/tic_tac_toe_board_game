import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tic_tac_toe_board_game/utils/app_assets.dart';

class FloatingParticlesBackground extends StatefulWidget {
  const FloatingParticlesBackground({super.key});

  @override
  State<FloatingParticlesBackground> createState() =>
      _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState
    extends State<FloatingParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random();

    // Generate 24 floating X/O particle structures to cover the full viewport
    _particles = List.generate(24, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.0002 + random.nextDouble() * 0.0006, // Drift slowly so it doesn't distract
        angle: random.nextDouble() * math.pi * 2,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.012,
        size: 20.0 + random.nextDouble() * 25.0,
        opacity: 0.07 + random.nextDouble() * 0.13, // Keep opacities low so it is subtle
        isCross: random.nextBool(),
      );
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _animationController.addListener(() {
      if (!mounted) return;
      setState(() {
        for (var p in _particles) {
          p.x += math.cos(p.angle) * p.speed;
          p.y += math.sin(p.angle) * p.speed;
          p.rotation += p.rotationSpeed;

          // Wrap boundaries with padding
          if (p.x < -0.15) p.x = 1.15;
          if (p.x > 1.15) p.x = -0.15;
          if (p.y < -0.15) p.y = 1.15;
          if (p.y > 1.15) p.y = -0.15;
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: _particles.map((p) {
            return Positioned(
              left: p.x * width,
              top: p.y * height,
              child: Transform.rotate(
                angle: p.rotation,
                child: Opacity(
                  opacity: p.opacity,
                  child: Image.asset(
                    p.isCross ? AppAssets.cross : AppAssets.circle,
                    width: p.size,
                    height: p.size,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double angle;
  double rotation;
  double rotationSpeed;
  double size;
  double opacity;
  bool isCross;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.opacity,
    required this.isCross,
  });
}
