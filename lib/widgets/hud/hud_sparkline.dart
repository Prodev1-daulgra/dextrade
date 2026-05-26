import 'package:flutter/material.dart';
import '../../core/theme/dex_colors.dart';

class HudSparkline extends StatelessWidget {
  final List<double> points;
  final Color color;
  final double height;

  const HudSparkline({
    super.key,
    required this.points,
    required this.color,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(height: height);
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparkPainter(points: points, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparkPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final minY = points.reduce((a, b) => a < b ? a : b);
    final maxY = points.reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).abs() < 0.001 ? 1.0 : maxY - minY;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height - ((points[i] - minY) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final lastX = size.width;
    final lastY =
        size.height - ((points.last - minY) / range) * size.height;
    canvas.drawCircle(
      Offset(lastX, lastY),
      3,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(lastX, lastY), 2, Paint()..color = DexColors.textPrimary);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.points != points;
}
