import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../pulse_dot.dart';

class HudScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? trailing;
  final bool live;

  const HudScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.live = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (live) ...[
                    const PulseDot(color: DexColors.success, size: 6),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE',
                      style: GoogleFonts.orbitron(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: DexColors.success,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: DexColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...trailing!,
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}
