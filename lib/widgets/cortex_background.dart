import 'package:flutter/material.dart';
import '../core/theme/dex_colors.dart';

class CortexBackground extends StatefulWidget {
  final Widget child;

  const CortexBackground({super.key, required this.child});

  @override
  State<CortexBackground> createState() => _CortexBackgroundState();
}

class _CortexBackgroundState extends State<CortexBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Dark Space
        Container(color: DexColors.background),
        
        // Animated Ambient Lemon Glow
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: -100 + (_controller.value * 200),
              top: -200 + (_controller.value * 100),
              child: Container(
                width: MediaQuery.of(context).size.width * 1.5,
                height: MediaQuery.of(context).size.height * 1.5,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      DexColors.primarySurface,
                      DexColors.background.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            );
          },
        ),

        // Grid/Dot Pattern Overlay
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: CustomPaint(
              painter: _DotGridPainter(),
            ),
          ),
        ),

        // Main Content
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
