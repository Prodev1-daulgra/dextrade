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
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          // Scale down when pressed, scale up slightly when hovered
          final currentScale = _isPressed ? _scaleAnim.value : (_isHovered ? 1.05 : 1.0);
          return Transform.scale(scale: currentScale, child: child);
        },
        child: GestureDetector(
          onTapDown: widget.onPressed != null ? _handleTapDown : null,
          onTapUp: widget.onPressed != null ? _handleTapUp : null,
          onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: widget.isPrimary
                  ? const LinearGradient(
                      colors: DexColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isPrimary ? null : (_isHovered ? Colors.white.withValues(alpha: 0.05) : DexColors.surfaceLight),
              border: widget.isPrimary
                  ? (_isHovered ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5) : null)
                  : Border.all(color: _isHovered ? DexColors.primary.withValues(alpha: 0.5) : DexColors.border),
              boxShadow: widget.isPrimary
                  ? [
                      BoxShadow(
                        color: DexColors.primary.withValues(alpha: _isHovered ? 0.6 : 0.3),
                        blurRadius: _isHovered ? 32 : 16,
                        spreadRadius: _isHovered ? 4 : 0,
                        offset: const Offset(0, 4),
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
                    color: widget.isPrimary
                        ? DexColors.background
                        : DexColors.primary,
                    glowStrength: 4,
                  ),
                  const SizedBox(width: 12),
                ] else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.isPrimary
                        ? DexColors.background
                        : DexColors.textPrimary,
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
      ),
    );
  }
}
