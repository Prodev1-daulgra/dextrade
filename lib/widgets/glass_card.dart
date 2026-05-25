import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/dex_colors.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final double blurAmount;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.borderColor,
    this.blurAmount = 20,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedScale(
      scale: _isHovered ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: DexColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurAmount + 16.0, // High-end frost blur
              sigmaY: widget.blurAmount + 16.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: _isHovered
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.01),
                border: Border.all(
                  color: _isHovered 
                    ? DexColors.primary.withValues(alpha: 0.3) 
                    : Colors.white.withValues(alpha: 0.08), 
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isHovered
                      ? [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.02),
                          DexColors.primary.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.02),
                        ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  // Inner top/left highlight for 3D bevel effect
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.12),
                    offset: const Offset(-1, -1),
                    blurRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(2, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: widget.padding ?? const EdgeInsets.all(24),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: widget.onTap != null
          ? GestureDetector(onTap: widget.onTap, child: card)
          : card,
    );
  }
}
