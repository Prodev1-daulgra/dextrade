import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../core/theme/dex_colors.dart';

class AnimatedMeshGradient extends StatefulWidget {
  final Widget? child;
  final List<Color> colors;
  
  const AnimatedMeshGradient({
    super.key, 
    this.child,
    this.colors = const [
      DexColors.primary,
      DexColors.accent,
      DexColors.info,
    ],
  });

  @override
  State<AnimatedMeshGradient> createState() => _AnimatedMeshGradientState();
}

class _AnimatedMeshGradientState extends State<AnimatedMeshGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
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
        // Dark background base
        Container(color: const Color(0xFF020205)),
        
        // Moving orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;
            
            // Generate oscillating positions using sine/cosine
            return Stack(
              children: [
                _buildOrb(
                  color: widget.colors[0].withValues(alpha: 0.15),
                  size: math.max(w, h) * 0.8,
                  x: (w * 0.5) + math.sin(t * math.pi * 2) * (w * 0.3),
                  y: (h * 0.3) + math.cos(t * math.pi * 2) * (h * 0.2),
                ),
                _buildOrb(
                  color: widget.colors[1].withValues(alpha: 0.12),
                  size: math.max(w, h) * 0.7,
                  x: (w * 0.8) + math.cos(t * math.pi * 2 + math.pi/2) * (w * 0.4),
                  y: (h * 0.7) + math.sin(t * math.pi * 2 + math.pi/2) * (h * 0.3),
                ),
                if (widget.colors.length > 2)
                  _buildOrb(
                    color: widget.colors[2].withValues(alpha: 0.1),
                    size: math.max(w, h) * 0.9,
                    x: (w * 0.2) + math.sin(t * math.pi * 2 + math.pi) * (w * 0.2),
                    y: (h * 0.8) + math.cos(t * math.pi * 2 + math.pi) * (h * 0.2),
                  ),
              ],
            );
          },
        ),
        
        // Extreme Blur overlay for mesh effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),
        ),
        
        // Content
        if (widget.child != null)
          Positioned.fill(child: widget.child!),
      ],
    );
  }

  Widget _buildOrb({
    required Color color,
    required double size,
    required double x,
    required double y,
  }) {
    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
