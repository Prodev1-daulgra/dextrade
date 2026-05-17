import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/dex_colors.dart';
import 'glow_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final bool isSmall;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaPressed,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glowing background
            Container(
              width: isSmall ? 64 : 80,
              height: isSmall ? 64 : 80,
              decoration: BoxDecoration(
                color: DexColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: DexColors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: isSmall ? 28 : 36,
                  color: DexColors.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Text Content
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: isSmall ? 16 : 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isSmall ? 12 : 14,
                fontWeight: FontWeight.w400,
                color: DexColors.textSecondary,
                height: 1.5,
              ),
            ),
            
            // Optional CTA
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: 32),
              GlowButton(
                label: ctaLabel!,
                onPressed: onCtaPressed,
                width: isSmall ? 160 : 200,
                isPrimary: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
