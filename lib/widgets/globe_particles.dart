import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/dex_colors.dart';

class GlobeParticles extends StatefulWidget {
  final double size;
  const GlobeParticles({super.key, this.size = 400});

  @override
  State<GlobeParticles> createState() => _GlobeParticlesState();
}

class _GlobeParticlesState extends State<GlobeParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _GlobePainter(_controller.value * 2 * math.pi),
          );
        },
      ),
    );
  }
}

class _GlobePainter extends CustomPainter {
  final double rotationY;
  _GlobePainter(this.rotationY);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;
    
    final paint = Paint()
      ..color = DexColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;
      
    final int numPoints = 800; // Dense particle field
    final double phi = math.pi * (3 - math.sqrt(5)); // Golden angle

    for (int i = 0; i < numPoints; i++) {
      final y = 1 - (i / (numPoints - 1)) * 2; // y goes from 1 to -1
      final r = math.sqrt(1 - y * y); // radius at y
      
      final theta = phi * i; // Golden angle increment
      
      // Apply Y-axis rotation
      final currentTheta = theta + rotationY;
      
      final x = math.cos(currentTheta) * r;
      final z = math.sin(currentTheta) * r;

      // Simple 3D projection
      final scale = 300 / (300 + z * radius); // Perspective scale
      final px = center.dx + x * radius * scale;
      final py = center.dy + y * radius * scale;

      // Fade based on z-depth (darker when particles are far away)
      final alpha = ((z + 1) / 2).clamp(0.05, 1.0);
      
      // Highlight particles closer to the equator (y ~ 0)
      final equatorGlow = (1 - y.abs()).clamp(0.0, 1.0);
      
      paint.color = DexColors.primary.withValues(
        alpha: alpha * (0.4 + (equatorGlow * 0.6)),
      );

      final dotSize = (1.2 + (equatorGlow * 1.5)) * scale;
      canvas.drawCircle(Offset(px, py), dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlobePainter oldDelegate) => 
      oldDelegate.rotationY != rotationY;
}
