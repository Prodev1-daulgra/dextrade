import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../pulse_dot.dart';

class HudStatusPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool pulse;

  const HudStatusPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: DexColors.textMuted,
                ),
              ),
              Row(
                children: [
                  if (pulse) ...[
                    PulseDot(color: color, size: 5),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    value,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
