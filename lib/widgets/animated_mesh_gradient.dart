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
      duration: const Duration(seconds: 40), // Slower, more elegant movement
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
        // Pure deep space black base
        Container(color: const Color(0xFF000000)),
        
        // Moving orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;
            
            // Generate oscillating positions using sine/cosine for fluid organic movement
            return Stack(
              children: [
                // Primary Neon Cyan Orb (Subtle)
                _buildOrb(
                  color: DexColors.primary.withValues(alpha: 0.12),
                  size: math.max(w, h) * 1.2,
                  x: (w * 0.4) + math.sin(t * math.pi * 2) * (w * 0.4),
                  y: (h * 0.4) + math.cos(t * math.pi * 2) * (h * 0.3),
                ),
                // Deep Blue Orb
                _buildOrb(
                  color: DexColors.primaryGlow.withValues(alpha: 0.10),
                  size: math.max(w, h) * 1.0,
                  x: (w * 0.6) + math.cos(t * math.pi * 2 + math.pi/3) * (w * 0.3),
                  y: (h * 0.7) + math.sin(t * math.pi * 2 + math.pi/3) * (h * 0.4),
                ),
                // Electric Accent (Yellow/Cyan mix)
                _buildOrb(
                  color: DexColors.accent.withValues(alpha: 0.05),
                  size: math.max(w, h) * 0.8,
                  x: (w * 0.8) + math.sin(t * math.pi * 2 + math.pi) * (w * 0.2),
                  y: (h * 0.2) + math.cos(t * math.pi * 2 + math.pi) * (h * 0.3),
                ),
                // Deep Dark Purple/Cyan mix for depth
                _buildOrb(
                  color: const Color(0xFF00C6FB).withValues(alpha: 0.08),
                  size: math.max(w, h) * 1.5,
                  x: (w * 0.2) + math.cos(t * math.pi * 2 + math.pi*1.5) * (w * 0.4),
                  y: (h * 0.8) + math.sin(t * math.pi * 2 + math.pi*1.5) * (h * 0.2),
                ),
              ],
            );
          },
        ),
        
        // Extreme Blur overlay for mesh effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
            child: Container(color: Colors.transparent),
          ),
        ),
        
        // Subtle Noise Overlay for premium texture
        Positioned.fill(
          child: Opacity(
            opacity: 0.03,
            child: Image.asset(
              'assets/images/noise.png', // Assuming there's a noise asset, otherwise it gracefully fails or we can remove
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
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
