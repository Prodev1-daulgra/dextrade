import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/dex_colors.dart';
import 'dex_shader_illustration.dart';

class MarketingFeaturePanel extends StatelessWidget {
  final String indexLabel;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final DexIllustrationKind illustration;
  final bool flip;
  final int animDelayMs;

  const MarketingFeaturePanel({
    super.key,
    required this.indexLabel,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.illustration,
    this.flip = false,
    this.animDelayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 960;
    final text = _buildCopy();
    final art = DexShaderIllustration(
      kind: illustration,
      height: isWide ? 340 : 260,
      width: isWide ? 420 : double.infinity,
    );

    final children = flip && isWide
        ? [Expanded(child: art), const SizedBox(width: 56), Expanded(child: text)]
        : isWide
            ? [Expanded(child: text), const SizedBox(width: 56), Expanded(child: art)]
            : [text, const SizedBox(height: 32), art];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 24,
        vertical: isWide ? 56 : 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: animDelayMs.ms, duration: 700.ms)
        .slideY(begin: 0.06, curve: Curves.easeOutCubic);
  }

  Widget _buildCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.rotate(
          angle: -0.08,
          child: Text(
            indexLabel,
            style: GoogleFonts.orbitron(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              height: 0.9,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 80)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.05,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: DexColors.textSecondary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 24),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: DexColors.primaryGradient),
                    boxShadow: [
                      BoxShadow(
                        color: DexColors.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    b,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: DexColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
