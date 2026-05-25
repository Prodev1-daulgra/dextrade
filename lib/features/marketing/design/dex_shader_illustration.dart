import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/dex_colors.dart';

/// Semi-3D procedural illustrations for marketing feature sections (no external assets).
enum DexIllustrationKind {
  mirrorCore,
  vaultLattice,
  matchEngine,
  liquidityNexus,
  copyStream,
}

class DexShaderIllustration extends StatefulWidget {
  final DexIllustrationKind kind;
  final double height;
  final double? width;

  const DexShaderIllustration({
    super.key,
    required this.kind,
    this.height = 320,
    this.width,
  });

  @override
  State<DexShaderIllustration> createState() => _DexShaderIllustrationState();
}

class _DexShaderIllustrationState extends State<DexShaderIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, __) {
          return CustomPaint(
            size: Size(widget.width ?? double.infinity, widget.height),
            painter: _DexIllustrationPainter(
              kind: widget.kind,
              phase: _spin.value,
            ),
          );
        },
      ),
    );
  }
}

class _DexIllustrationPainter extends CustomPainter {
  final DexIllustrationKind kind;
  final double phase;

  _DexIllustrationPainter({required this.kind, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    final r = math.min(size.width, size.height) * 0.38;

    _drawGlowPlate(canvas, size);

    switch (kind) {
      case DexIllustrationKind.mirrorCore:
        _drawMirrorCore(canvas, cx, cy, r);
      case DexIllustrationKind.vaultLattice:
        _drawVaultLattice(canvas, cx, cy, r);
      case DexIllustrationKind.matchEngine:
        _drawMatchEngine(canvas, cx, cy, r);
      case DexIllustrationKind.liquidityNexus:
        _drawLiquidityNexus(canvas, cx, cy, r);
      case DexIllustrationKind.copyStream:
        _drawCopyStream(canvas, cx, cy, r);
    }
  }

  void _drawGlowPlate(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(28),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DexColors.primary.withValues(alpha: 0.12),
            Colors.transparent,
            DexColors.accent.withValues(alpha: 0.08),
          ],
        ).createShader(rect.outerRect),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.08),
    );
  }

  void _drawMirrorCore(Canvas canvas, double cx, double cy, double r) {
    final ring = phase * math.pi * 2;
    for (var i = 0; i < 3; i++) {
      final rr = r * (0.55 + i * 0.18);
      canvas.drawCircle(
        Offset(cx, cy),
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = DexColors.primary.withValues(alpha: 0.25 - i * 0.05),
      );
    }
    for (var i = 0; i < 6; i++) {
      final a = ring + i * math.pi / 3;
      final p = Offset(cx + math.cos(a) * r * 0.72, cy + math.sin(a) * r * 0.45);
      _drawNode(canvas, p, DexColors.accent, 14);
      canvas.drawLine(Offset(cx, cy), p, Paint()
        ..color = DexColors.primary.withValues(alpha: 0.35)
        ..strokeWidth = 1.2);
    }
    _drawNode(canvas, Offset(cx, cy), DexColors.primaryGlow, 22);
  }

  void _drawVaultLattice(Canvas canvas, double cx, double cy, double r) {
    final cube = r * 0.55;
    final iso = [
      Offset(cx - cube, cy),
      Offset(cx, cy - cube * 0.55),
      Offset(cx + cube, cy),
      Offset(cx, cy + cube * 0.55),
    ];
    final path = Path()
      ..moveTo(iso[0].dx, iso[0].dy)
      ..lineTo(iso[1].dx, iso[1].dy)
      ..lineTo(iso[2].dx, iso[2].dy)
      ..lineTo(iso[3].dx, iso[3].dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            DexColors.primary.withValues(alpha: 0.5),
            DexColors.primaryDark.withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = DexColors.accent.withValues(alpha: 0.6)
        ..strokeWidth = 2,
    );
    for (var i = 0; i < 4; i++) {
      final t = (phase + i * 0.25) % 1.0;
      final y = cy - cube + t * cube * 1.2;
      canvas.drawLine(
        Offset(cx - cube * 0.7, y),
        Offset(cx + cube * 0.7, y),
        Paint()
          ..color = DexColors.accent.withValues(alpha: 0.15)
          ..strokeWidth = 1,
      );
    }
  }

  void _drawMatchEngine(Canvas canvas, double cx, double cy, double r) {
    final bars = 12;
    for (var i = 0; i < bars; i++) {
      final h = r * (0.25 + 0.55 * math.sin(phase * math.pi * 2 + i * 0.7).abs());
      final x = cx - r + (2 * r / bars) * i + 6;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, cy), width: 10, height: h),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              DexColors.primary,
              DexColors.accent.withValues(alpha: 0.8),
            ],
          ).createShader(rect.outerRect),
      );
    }
    canvas.drawLine(
      Offset(cx - r, cy - r * 0.3),
      Offset(cx + r, cy - r * 0.1),
      Paint()
        ..color = DexColors.success.withValues(alpha: 0.8)
        ..strokeWidth = 2,
    );
  }

  void _drawLiquidityNexus(Canvas canvas, double cx, double cy, double r) {
    for (var ring = 1; ring <= 4; ring++) {
      final path = Path();
      for (var a = 0.0; a <= math.pi * 2; a += 0.15) {
        final wobble = math.sin(a * 3 + phase * math.pi * 2) * 12;
        final rr = r * 0.25 * ring + wobble;
        final p = Offset(cx + math.cos(a) * rr, cy + math.sin(a) * rr * 0.65);
        a == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = DexColors.accent.withValues(alpha: 0.2 / ring),
      );
    }
  }

  void _drawCopyStream(Canvas canvas, double cx, double cy, double r) {
    for (var i = 0; i < 5; i++) {
      final t = (phase + i * 0.18) % 1.0;
      final x = cx - r + t * r * 2;
      final y = cy + math.sin(t * math.pi * 2) * r * 0.25;
      _drawNode(canvas, Offset(x, y), DexColors.primaryGlow, 10 + i.toDouble());
    }
    canvas.drawCircle(
      Offset(cx + r * 0.35, cy),
      r * 0.2,
      Paint()..color = DexColors.accent.withValues(alpha: 0.15),
    );
  }

  void _drawNode(Canvas canvas, Offset c, Color color, double size) {
    canvas.drawCircle(
      c,
      size,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0.1)],
        ).createShader(Rect.fromCircle(center: c, radius: size)),
    );
    canvas.drawCircle(
      c,
      size,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_DexIllustrationPainter old) => old.phase != phase;
}
