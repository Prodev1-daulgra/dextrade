import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';

class HudTimeframeChips extends StatelessWidget {
  final List<String> timeframes;
  final String selected;
  final ValueChanged<String> onSelected;
  final Color? accent;

  const HudTimeframeChips({
    super.key,
    required this.timeframes,
    required this.selected,
    required this.onSelected,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? DexColors.accent;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeframes.map((tf) {
          final active = tf == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(tf);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: active
                      ? color.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: active
                        ? color.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  tf,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: active ? color : DexColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
