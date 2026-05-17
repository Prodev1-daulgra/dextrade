import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/dex_colors.dart';

class GlowMorphLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final double glowStrength;

  const GlowMorphLoader({
    super.key,
    this.size = 80,
    this.color,
    this.glowStrength = 20,
  });

  @override
  State<GlowMorphLoader> createState() => _GlowMorphLoaderState();
}

class _GlowMorphLoaderState extends State<GlowMorphLoader>
    with TickerProviderStateMixin {
  late final AnimationController _morphController;
  late final AnimationController _pingController;
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _morphController.dispose();
    _pingController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? DexColors.primary;
    final secondaryColor = DexColors.accent;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_morphController, _pingController, _rotateController]),
        builder: (context, _) {
          return CustomPaint(
            painter: _GlowMorphPainter(
              morphProgress: _morphController.value,
              pingProgress: _pingController.value,
              rotation: _rotateController.value * 2 * math.pi,
              primaryColor: activeColor,
              accentColor: secondaryColor,
              glowStrength: widget.glowStrength,
            ),
          );
        },
      ),
    );
  }
}

class _GlowMorphPainter extends CustomPainter {
  final double morphProgress;
  final double pingProgress;
  final double rotation;
  final Color primaryColor;
  final Color accentColor;
  final double glowStrength;

  _GlowMorphPainter({
    required this.morphProgress,
    required this.pingProgress,
    required this.rotation,
    required this.primaryColor,
    required this.accentColor,
    required this.glowStrength,
  });

  // Calculate coordinates for 60 points representing a shape
  List<Offset> _getPointsForShape(int shapeIndex, double radius, Offset center) {
    const int count = 60;
    final List<Offset> points = [];

    for (int i = 0; i < count; i++) {
      final double angle = (i * 2 * math.pi / count);

      switch (shapeIndex) {
        case 0: // Circle
          points.add(center + Offset(radius * math.cos(angle), radius * math.sin(angle)));
          break;

        case 1: // Squircle (Rounded Square)
          final double cosVal = math.cos(angle);
          final double sinVal = math.sin(angle);
          // Mathematical Superellipse mapping
          final double r = radius * (1.0 / math.pow(math.pow(cosVal.abs(), 4.0) + math.pow(sinVal.abs(), 4.0), 0.25));
          points.add(center + Offset(r * cosVal, r * sinVal));
          break;

        case 2: // Triangle
          // Map to 3 vertices
          final double k = (angle + math.pi / 6) % (2 * math.pi / 3) - (math.pi / 3);
          final double r = radius * math.cos(math.pi / 3) / math.cos(k);
          // Rotate 90 deg so triangle points upwards
          final double adjustedAngle = angle - math.pi / 2;
          points.add(center + Offset(r * math.cos(adjustedAngle), r * math.sin(adjustedAngle)));
          break;

        case 3: // Hexagon
          final double k = (angle + math.pi / 6) % (2 * math.pi / 6) - (math.pi / 6);
          final double r = radius * math.cos(math.pi / 6) / math.cos(k);
          points.add(center + Offset(r * math.cos(angle), r * math.sin(angle)));
          break;

        default: // Circle default fallback
          points.add(center + Offset(radius * math.cos(angle), radius * math.sin(angle)));
          break;
      }
    }
    return points;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.26;

    // ─── 1. Beep/Ping Expanding Outer Waves (Radar effect) ───
    final pingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 2; i++) {
      final double progress = (pingProgress + i * 0.5) % 1.0;
      final double scale = 1.0 + progress * 2.2;
      final double opacity = (1.0 - progress) * 0.35;
      final double radius = baseRadius * scale;

      pingPaint.shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(opacity),
          accentColor.withOpacity(opacity * 0.5),
          Colors.transparent,
        ],
        stops: const [0.7, 0.9, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, pingPaint);
    }

    // ─── 2. Interpolate morph points ───
    // 4 stages: Shape 0 -> 1 -> 2 -> 3 -> 0
    final double stageDouble = morphProgress * 4.0;
    final int currentStage = stageDouble.floor() % 4;
    final double t = stageDouble - stageDouble.floor();

    final int nextStage = (currentStage + 1) % 4;

    final List<Offset> p1 = _getPointsForShape(currentStage, baseRadius, center);
    final List<Offset> p2 = _getPointsForShape(nextStage, baseRadius, center);

    final List<Offset> morphedPoints = [];
    for (int i = 0; i < 60; i++) {
      // Rotate coordinates slightly for organic motion
      final rotatedIndex = (i + (rotation * 60 / (2 * math.pi)).floor()) % 60;
      morphedPoints.add(Offset.lerp(p1[i], p2[rotatedIndex], Curves.easeInOut.transform(t))!);
    }

    final path = Path()..moveTo(morphedPoints[0].dx, morphedPoints[0].dy);
    for (int i = 1; i < 60; i++) {
      path.lineTo(morphedPoints[i].dx, morphedPoints[i].dy);
    }
    path.close();

    // ─── 3. Shadow / Neon Aura Glow ───
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowStrength);
    canvas.drawPath(path, glowPaint);

    final glowPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = accentColor.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glowPaint2);

    // ─── 4. Main Morphing Fill Shape with Chrome Iridescent Gradient ───
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          primaryColor,
          accentColor,
          primaryColor.withOpacity(0.8),
          accentColor,
          primaryColor,
        ],
        transform: GradientRotation(rotation),
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    canvas.drawPath(path, fillPaint);

    // ─── 5. Glass Reflection Overlay (Highlights) ───
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.1),
          Colors.transparent,
          primaryColor.withOpacity(0.4),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowMorphPainter oldDelegate) => true;
}
