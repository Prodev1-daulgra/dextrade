import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/dex_colors.dart';

/// Lightweight animated aurora — replaces heavy mesh + timer scroll on marketing pages.
class MarketingAmbientScene extends StatefulWidget {
  final Widget child;
  final bool animate;

  const MarketingAmbientScene({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<MarketingAmbientScene> createState() => _MarketingAmbientSceneState();
}

class _MarketingAmbientSceneState extends State<MarketingAmbientScene>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 24),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _AuroraPainter(t: _controller?.value ?? 0),
            child: const SizedBox.expand(),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  _AuroraPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 99999, 99999),
      Paint()..color = const Color(0xFF020208),
    );

    final orbs = [
      (Offset(size.width * 0.15, size.height * 0.2), DexColors.primary, 220.0),
      (Offset(size.width * 0.85, size.height * 0.35), DexColors.accent, 180.0),
      (Offset(size.width * 0.5, size.height * 0.75), DexColors.accentGlow, 260.0),
    ];

    for (var i = 0; i < orbs.length; i++) {
      final (base, color, radius) = orbs[i];
      final drift = Offset(
        math.sin(t * math.pi * 2 + i) * 40,
        math.cos(t * math.pi * 2 + i * 1.3) * 30,
      );
      final center = base + drift;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    // Subtle grid
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 1;
    const step = 48.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}
