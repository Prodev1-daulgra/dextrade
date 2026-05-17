import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glow_morph_loader.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';

class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final double? width;

  const GlowButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.width,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _controller.forward();
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _handleTapDown : null,
        onTapUp: widget.onPressed != null ? _handleTapUp : null,
        onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isPrimary
                ? const LinearGradient(
                    colors: DexColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isPrimary ? null : DexColors.surfaceLight,
            border: widget.isPrimary
                ? null
                : Border.all(color: DexColors.border),
            boxShadow: widget.isPrimary && _isPressed
                ? [
                    BoxShadow(
                      color: DexColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ]
                : widget.isPrimary
                    ? [
                        BoxShadow(
                          color: DexColors.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                GlowMorphLoader(
                  size: 20,
                  color: widget.isPrimary ? DexColors.background : DexColors.primary,
                  glowStrength: 4,
                ),
                const SizedBox(width: 12),
              ] else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isPrimary ? DexColors.background : DexColors.textPrimary,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label.toUpperCase(),
                style: widget.isPrimary
                    ? DexTypography.buttonLarge
                    : DexTypography.button,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
