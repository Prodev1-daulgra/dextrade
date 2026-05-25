import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glow_button.dart';
import '../marketing/design/dex_shader_illustration.dart';
import '../marketing/design/marketing_ambient_scene.dart';
import '../marketing/design/marketing_download_cta.dart';
import '../marketing/design/marketing_feature_panel.dart';
import '../marketing/design/marketing_marquee.dart';
import '../marketing/marketing_shell.dart';

/// Brand-forward landing — asymmetric editorial layout, shader art, performant motion.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 960;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MarketingAmbientScene(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 108),
              _HeroSection(wide: wide),
              _TickerStrip(),
              _StatsBreak(wide: wide),
              const MarketingFeaturePanel(
                indexLabel: '01',
                title: 'Mirror Protocol',
                subtitle:
                    'Clone elite desks without surrendering custody. Allocation rails, risk caps, and sovereign kill-switches built in.',
                bullets: [
                  'Sub-50ms mirror sync simulation layer',
                  'Per-trader allocation vaults',
                  'One-tap detach — capital returns instantly',
                ],
                illustration: DexIllustrationKind.mirrorCore,
                animDelayMs: 100,
              ),
              const MarketingFeaturePanel(
                indexLabel: '02',
                title: 'Match Engine Core',
                subtitle:
                    'Order flow visualized as living geometry — not another three-column SaaS grid.',
                bullets: [
                  'Depth-aware charting in the terminal',
                  'Batch approval for institutional desks',
                  'Native Dex keypad for size entry',
                ],
                illustration: DexIllustrationKind.matchEngine,
                flip: true,
                animDelayMs: 200,
              ),
              const MarketingFeaturePanel(
                indexLabel: '03',
                title: 'Cold Custody Lattice',
                subtitle:
                    'Multi-sig policy mesh rendered as an isometric vault — security you can see.',
                bullets: [
                  'Segregated balance rails per strategy',
                  'State-admin approval portal on web',
                  'Push-style in-app alerts with custom chrome',
                ],
                illustration: DexIllustrationKind.vaultLattice,
                animDelayMs: 300,
              ),
              _TerminalPreview(wide: wide),
              _SocialProof(wide: wide),
              const MarketingDownloadCta(),
              _FinalCta(wide: wide),
              const MarketingFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool wide;
  const _HeroSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        _Pill('SOVEREIGN COPYTRADING TERMINAL'),
        const SizedBox(height: 28),
        Text(
          'Liquidity',
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: wide ? 88 : 52,
            fontWeight: FontWeight.w900,
            height: 0.95,
            letterSpacing: -3,
            color: Colors.white,
          ),
        ),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [DexColors.primaryGlow, DexColors.accent, DexColors.accentGlow],
          ).createShader(b),
          child: Text(
            'without permission.',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: wide ? 88 : 52,
              fontWeight: FontWeight.w900,
              height: 0.95,
              letterSpacing: -3,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Dextrade is a Web3-native execution surface — mirror desks, approve flow, and vault balances in one cinematic terminal. Not a template. A protocol brand.',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 17,
              color: DexColors.textSecondary,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            GlowButton(
              label: 'LAUNCH TERMINAL',
              onPressed: () => context.push('/register'),
              width: 220,
            ),
            GlowButton(
              label: 'EXPLORE PLATFORM',
              isPrimary: false,
              onPressed: () => context.go('/features'),
              width: 220,
            ),
          ],
        ),
      ],
    );

    final art = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: wide ? -40 : 0,
          top: wide ? -20 : 0,
          child: Transform.rotate(
            angle: -0.12,
            child: Text(
              'DEX',
              style: GoogleFonts.orbitron(
                fontSize: wide ? 200 : 120,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
        ),
        DexShaderIllustration(
          kind: DexIllustrationKind.liquidityNexus,
          height: wide ? 380 : 280,
          width: wide ? 480 : double.infinity,
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 11, child: copy),
                    const SizedBox(width: 40),
                    Expanded(flex: 10, child: art),
                  ],
                )
              : Column(children: [copy, const SizedBox(height: 40), art]),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.04);
  }
}

class _TickerStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: MarketingMarquee(
        items: const [
          'BTC +2.4%',
          'ETH +1.8%',
          'SOL +5.2%',
          'MIRROR SYNC LIVE',
          'COLD CUSTODY ON',
          'DEX KEYPAD v2',
        ],
        style: GoogleFonts.orbitron(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: DexColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _StatsBreak extends StatelessWidget {
  final bool wide;
  const _StatsBreak({required this.wide});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('\$2.4B+', 'Simulated mirror volume'),
      ('<50ms', 'Sync target'),
      ('180+', 'Curated desks'),
      ('0', 'Template layouts'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 20, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: wide ? 4 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: wide ? 1.8 : 1.4,
            children: stats.map((s) {
              return Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: DexColors.surface.withValues(alpha: 0.6),
                  border: Border.all(color: DexColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.$1,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.$2,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DexColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TerminalPreview extends StatelessWidget {
  final bool wide;
  const _TerminalPreview({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                'THE TERMINAL, FRAMED LIKE ART',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: DexColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: DexColors.primary.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: DexColors.primary.withValues(alpha: 0.15),
                      blurRadius: 60,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        color: const Color(0xFF120A1E),
                        child: Row(
                          children: [
                            _dot(Colors.redAccent),
                            _dot(Colors.amber),
                            _dot(DexColors.success),
                            const SizedBox(width: 16),
                            Text(
                              'dextrade://mirror-session',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: DexColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const DexShaderIllustration(
                        kind: DexIllustrationKind.copyStream,
                        height: 220,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _SocialProof extends StatelessWidget {
  final bool wide;
  const _SocialProof({required this.wide});

  @override
  Widget build(BuildContext context) {
    final quotes = [
      ('"Feels like a Framer crypto drop, not SaaS."', 'Desk Lead, EU'),
      ('"Mirror flow is finally readable."', 'Quant, APAC'),
      ('"Custom push chrome sold our team."', 'Ops, US'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: quotes.map((q) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(28),
                    topRight: const Radius.circular(8),
                    bottomLeft: const Radius.circular(8),
                    bottomRight: const Radius.circular(28),
                  ),
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.$1,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      q.$2,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DexColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _FinalCta extends StatelessWidget {
  final bool wide;
  const _FinalCta({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 48 : 24, 48, wide ? 48 : 24, 80),
      child: Center(
        child: GlowButton(
          label: 'CREATE SOVEREIGN ACCOUNT',
          onPressed: () => context.push('/register'),
          width: wide ? 320 : double.infinity,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: DexColors.primary.withValues(alpha: 0.4)),
        color: DexColors.primary.withValues(alpha: 0.08),
      ),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
          color: DexColors.primary,
        ),
      ),
    );
  }
}
