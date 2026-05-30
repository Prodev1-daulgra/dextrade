import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/dex_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final double blur;
  final bool hasGlow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.blur = 20.0,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? DexColors.surfaceGlass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? DexColors.border,
              width: 1.0,
            ),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: DexColors.primary.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
