import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/dex_colors.dart';
import '../../../widgets/glow_button.dart';

class MarketingDownloadCta extends StatelessWidget {
  const MarketingDownloadCta({super.key});

  static const androidApkUrl = '/app-release.apk';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24),
      padding: EdgeInsets.all(isWide ? 40 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DexColors.primary.withValues(alpha: 0.18),
            const Color(0xFF0A0614),
            DexColors.accent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: DexColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: [
          Text(
            'TAKE THE TERMINAL WITH YOU',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              letterSpacing: 3,
              color: DexColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Native Android build with Dex keypad.\niOS vault launching soon.',
            textAlign: isWide ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.spaceGrotesk(
              fontSize: isWide ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: isWide ? WrapAlignment.center : WrapAlignment.start,
            children: [
              _StoreButton(
                icon: Icons.android_rounded,
                label: 'Download for Android',
                sublabel: 'APK • Latest build',
                primary: true,
                onTap: () => _launchApk(),
              ),
              const _StoreButton(
                icon: Icons.apple_rounded,
                label: 'iOS',
                sublabel: 'Coming Soon',
                disabled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchApk() async {
    final uri = kIsWeb
        ? Uri.parse(androidApkUrl)
        : Uri.parse('https://dextrade-tau.vercel.app$androidApkUrl');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool primary;
  final bool disabled;
  final VoidCallback? onTap;

  const _StoreButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.primary = false,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (primary && !disabled) {
      return GlowButton(
        label: label.toUpperCase(),
        onPressed: onTap,
        width: 260,
        icon: icon,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: disabled
                ? Colors.white.withValues(alpha: 0.03)
                : DexColors.surfaceLight,
            border: Border.all(
              color: disabled
                  ? Colors.white.withValues(alpha: 0.06)
                  : DexColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: disabled ? DexColors.textDim : DexColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      color: disabled ? DexColors.textDim : Colors.white,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: DexColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
