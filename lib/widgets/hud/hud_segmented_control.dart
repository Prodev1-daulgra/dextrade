import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';

/// Animated segmented control with glow active rail.
class HudSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? accent;

  const HudSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? DexColors.primary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i != selectedIndex) {
                  HapticFeedback.selectionClick();
                  onChanged(i);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: active ? color.withValues(alpha: 0.18) : Colors.transparent,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.25),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: active ? Colors.white : DexColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
