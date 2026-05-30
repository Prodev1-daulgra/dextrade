import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/dex_colors.dart';

class DexGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool hasGlow;
  final VoidCallback? onTap;

  const DexGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius = 32,
    this.hasGlow = false,
    this.onTap,
  });

  @override
  State<DexGlassCard> createState() => _DexGlassCardState();
}

class _DexGlassCardState extends State<DexGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCirc,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: DexColors.surfaceGlass,
            border: Border.all(
              color: _isHovered 
                ? DexColors.primary.withValues(alpha: 0.4) 
                : DexColors.borderLight,
              width: 1,
            ),
            boxShadow: _isHovered && widget.hasGlow
                ? [
                    BoxShadow(
                      color: DexColors.primary.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius - 1),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
