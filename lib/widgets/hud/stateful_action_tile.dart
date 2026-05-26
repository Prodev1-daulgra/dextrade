import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';

/// Quick-action tile with press scale + optional active glow (stateful icon behavior).
class StatefulActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final bool isActive;
  final VoidCallback onTap;

  const StatefulActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<StatefulActionTile> createState() => _StatefulActionTileState();
}

class _StatefulActionTileState extends State<StatefulActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive || _down;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _down = true);
        _press.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _down = false);
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _down = false);
        _press.reverse();
      },
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) {
          return Transform.scale(
            scale: 1 - _press.value * 0.06,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: active
                ? widget.accent.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.03),
            border: Border.all(
              color: active
                  ? widget.accent.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.06),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.25),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: active ? widget.accent : DexColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                widget.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: active ? Colors.white : DexColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
