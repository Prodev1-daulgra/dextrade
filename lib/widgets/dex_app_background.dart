import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/dex_colors.dart';

/// App-wide HUD backdrop: black base + subtle grid + violet/cyan aurora.
class DexAppBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const DexAppBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<DexAppBackground> createState() => _DexAppBackgroundState();
}

class _DexAppBackgroundState extends State<DexAppBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 28),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _HudBackdropPainter(t: _c?.value ?? 0),
            child: const SizedBox.expand(),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _HudBackdropPainter extends CustomPainter {
  final double t;
  _HudBackdropPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF020204),
    );

    final orbs = [
      (Offset(size.width * 0.12, size.height * 0.08), DexColors.primary, 280.0),
      (Offset(size.width * 0.88, size.height * 0.15), DexColors.accent, 220.0),
      (Offset(size.width * 0.5, size.height * 0.55), DexColors.accentGlow, 320.0),
    ];

    for (var i = 0; i < orbs.length; i++) {
      final (base, color, radius) = orbs[i];
      final drift = Offset(
        math.sin(t * math.pi * 2 + i) * 24,
        math.cos(t * math.pi * 2 + i * 1.2) * 18,
      );
      final center = base + drift;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.02),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.022)
      ..strokeWidth = 1;
    const step = 44.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.65),
        ],
        stops: const [0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(_HudBackdropPainter old) => old.t != t;
}
