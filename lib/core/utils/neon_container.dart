import 'package:flutter/material.dart';
import '../theme/dex_colors.dart';

class NeonContainer extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final double borderRadius;
  final Color glowColor;

  const NeonContainer({
    super.key,
    required this.child,
    this.isActive = false,
    this.borderRadius = 16.0,
    this.glowColor = DexColors.accent,
  });

  @override
  State<NeonContainer> createState() => _NeonContainerState();
}

class _NeonContainerState extends State<NeonContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                : [],
            border: Border.all(
              color: widget.isActive 
                  ? widget.glowColor.withOpacity(0.5 + (0.5 * _glowAnimation.value))
                  : DexColors.border,
              width: widget.isActive ? 1.5 : 1.0,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
