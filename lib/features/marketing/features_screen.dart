import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glow_button.dart';
import 'design/dex_shader_illustration.dart';
import 'design/marketing_download_cta.dart';
import 'design/marketing_feature_panel.dart';
import 'design/marketing_page_scaffold.dart';
import 'marketing_shell.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;

    return MarketingPageScaffold(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLATFORM',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: DexColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Every module is a\nscene, not a section.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: wide ? 56 : 36,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Inspired by premium Web3 marketing systems — asymmetric rhythm, procedural shaders, editorial type.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: DexColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                children: [
                  _Chip('Mirror'),
                  _Chip('Trade'),
                  _Chip('Vault'),
                  _Chip('Admin'),
                  _Chip('Alerts'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const MarketingFeaturePanel(
          indexLabel: '01',
          title: 'Copy Trading Mirror',
          subtitle:
              'Follow curated desks with allocation sliders and live PnL sparklines in-terminal.',
          bullets: [
            'Trader discovery grid with risk bands',
            'Pending → approved mirror lifecycle',
            'Detach without leaving the app',
          ],
          illustration: DexIllustrationKind.mirrorCore,
        ),
        const MarketingFeaturePanel(
          indexLabel: '02',
          title: 'Pro Trade Surface',
          subtitle:
              'Charts, order tickets, and the Dex keypad — built for thumb and desk.',
          bullets: [
            'FL Chart micro-visuals',
            'Buy/sell with admin approval',
            'Custom toast + push notification stack',
          ],
          illustration: DexIllustrationKind.matchEngine,
          flip: true,
        ),
        const MarketingFeaturePanel(
          indexLabel: '03',
          title: 'Vault & Transactions',
          subtitle: 'Deposit and withdrawal rails with cinematic status modals.',
          bullets: [
            'QR-ready deposit flow',
            'Transaction timeline with badges',
            'Real-time balance hero on dashboard',
          ],
          illustration: DexIllustrationKind.vaultLattice,
        ),
        _BentoCapabilities(wide: wide),
        const MarketingDownloadCta(),
        Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: GlowButton(
              label: 'START FREE',
              onPressed: () => context.push('/register'),
              width: 280,
            ),
          ),
        ),
        const MarketingFooter(),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: DexColors.borderLight),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 9,
          letterSpacing: 1.5,
          color: DexColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BentoCapabilities extends StatelessWidget {
  final bool wide;
  const _BentoCapabilities({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: wide ? 3 : 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: wide ? 1.1 : 1.6,
            children: [
              _bento('Dashboard', 'Live balance hero, quick actions, onboarding rail', DexIllustrationKind.liquidityNexus),
              _bento('Settings', 'Profile, security, sign-out to marketing', DexIllustrationKind.copyStream),
              _bento('Superadmin', 'User governance for protocol ops', DexIllustrationKind.mirrorCore),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bento(String title, String desc, DexIllustrationKind kind) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: DexColors.card,
        border: Border.all(color: DexColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: DexShaderIllustration(kind: kind, height: 120)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.inter(fontSize: 12, color: DexColors.textMuted),
          ),
        ],
      ),
    );
  }
}
