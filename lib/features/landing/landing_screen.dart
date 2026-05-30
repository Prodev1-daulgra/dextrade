import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/utils/glass_container.dart';
import '../../core/utils/neon_container.dart';
import '../../widgets/glow_button.dart';
import '../marketing/design/marketing_ambient_scene.dart';
import '../marketing/design/marketing_download_cta.dart';
import '../marketing/design/marketing_marquee.dart';
import '../marketing/marketing_shell.dart';

/// Ultra-Premium Brand-forward landing — asymmetric editorial layout, deep glassmorphism.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 960;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MarketingAmbientScene(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 108),
              _HeroSection(wide: wide),
              _TickerStrip(),
              _StatsBreak(wide: wide),
              _ProTerminalShowcase(wide: wide),
              _FeaturesGrid(wide: wide),
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
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        _Pill('NEXT-GEN SOVEREIGN TERMINAL'),
        const SizedBox(height: 28),
        Text(
          'Trade the Future.',
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
            colors: [DexColors.accent, DexColors.accentGlow, DexColors.primary],
          ).createShader(b),
          child: Text(
            'Decentralized & Limitless.',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: wide ? 64 : 42,
              fontWeight: FontWeight.w900,
              height: 0.95,
              letterSpacing: -2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Experience institutional-grade execution on a decentralized architecture. Zero latency, maximum security, and a beautiful pro trading terminal.',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              color: DexColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            NeonContainer(
              isActive: true,
              glowColor: DexColors.primary,
              borderRadius: 100,
              child: GlowButton(
                label: 'START TRADING NOW',
                onPressed: () => context.go('/trade'),
                width: 240,
              ),
            ),
            GlassContainer(
              borderRadius: 100,
              color: Colors.white.withOpacity(0.05),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => context.go('/features'),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: Text(
                    'EXPLORE PLATFORM',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final art = NeonContainer(
      isActive: true,
      glowColor: DexColors.accent,
      borderRadius: 32,
      child: GlassContainer(
        blur: 40,
        borderRadius: 32,
        color: DexColors.surfaceLight.withOpacity(0.3),
        borderColor: DexColors.borderLight,
        child: Container(
          height: wide ? 500 : 350,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: RadialGradient(
              colors: [
                DexColors.primaryGlow.withOpacity(0.2),
                Colors.transparent,
              ],
              radius: 0.8,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Abstract floating geometry
              ...List.generate(3, (i) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 2 * pi),
                  duration: Duration(seconds: 20 + (i * 5)),
                  builder: (_, double angle, __) {
                    return Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 150.0 + (i * 80),
                        height: 150.0 + (i * 80),
                        decoration: BoxDecoration(
                          shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: i % 2 != 0 ? BorderRadius.circular(40) : null,
                          border: Border.all(
                            color: DexColors.accent.withOpacity(0.1 + (i * 0.1)),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              Text(
                'DEX',
                style: GoogleFonts.orbitron(
                  fontSize: wide ? 120 : 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: DexColors.primary,
                      blurRadius: 40,
                    )
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds)
                  .shimmer(duration: 3.seconds, color: DexColors.accent),
            ],
          ),
        ),
      ),
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
                    Expanded(flex: 12, child: copy),
                    const SizedBox(width: 60),
                    Expanded(flex: 10, child: art),
                  ],
                )
              : Column(children: [copy, const SizedBox(height: 60), art]),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.04);
  }
}

class _TickerStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: DexColors.primary.withOpacity(0.05),
        border: Border.symmetric(
          horizontal: BorderSide(color: DexColors.primary.withOpacity(0.2)),
        ),
      ),
      child: MarketingMarquee(
        items: const [
          'HYPER-LIQUID ENGINE',
          'ZERO GAS FEES',
          'SELF-CUSTODIAL',
          'PRO TERMINAL UI',
          'L2 VALIDIUM ARCHITECTURE',
        ],
        style: GoogleFonts.orbitron(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: DexColors.accentGlow,
          letterSpacing: 4,
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
      ('\$10B+', 'Quarterly Volume'),
      ('0ms', 'Gas Latency'),
      ('100%', 'Self-Custodial'),
      ('24/7', 'Market Access'),
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
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: wide ? 1.8 : 1.4,
            children: stats.map((s) {
              return GlassContainer(
                blur: 20,
                color: DexColors.surfaceLight.withOpacity(0.4),
                borderColor: DexColors.borderLight,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.$1,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: DexColors.accent,
                        shadows: [
                          Shadow(color: DexColors.accent.withOpacity(0.5), blurRadius: 20)
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.$2,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

class _ProTerminalShowcase extends StatelessWidget {
  final bool wide;
  const _ProTerminalShowcase({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'BUILT FOR PROFESSIONALS',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  letterSpacing: 4,
                  color: DexColors.accentGlow,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A Terminal That Feels Alive',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: wide ? 48 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              NeonContainer(
                isActive: true,
                glowColor: DexColors.primaryDark,
                borderRadius: 24,
                child: GlassContainer(
                  borderRadius: 24,
                  blur: 30,
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      height: wide ? 600 : 300,
                      decoration: BoxDecoration(
                        color: DexColors.surface,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/terminal_mockup.png'),
                          fit: BoxFit.cover,
                          opacity: 0.3,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.show_chart_rounded, size: 80, color: DexColors.accent),
                            const SizedBox(height: 16),
                            Text(
                              'ADVANCED CHARTING UI PLACEHOLDER',
                              style: GoogleFonts.orbitron(
                                color: DexColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  final bool wide;
  const _FeaturesGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unrivaled Performance',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: wide ? 48 : 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Built for professional traders who demand execution speed and deep liquidity without giving up custody.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: DexColors.textMuted,
                ),
              ),
              const SizedBox(height: 48),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: wide ? 2 : 1,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: wide ? 1.5 : 1.2,
                children: [
                  _FeatureCard(
                    title: 'Hyper-Liquid Engine',
                    desc: 'Access deep liquidity pools powered by our proprietary cross-chain matching engine. Execute massive orders with zero slippage.',
                    glowColor: DexColors.primary,
                  ),
                  _FeatureCard(
                    title: 'Zero Gas Fees',
                    desc: 'Gasless trades powered by our L2 validium architecture. You only pay for what you trade.',
                    glowColor: DexColors.accent,
                  ),
                  _FeatureCard(
                    title: 'Self-Custodial',
                    desc: 'Your keys, your crypto. Dextrade never holds your assets, ensuring absolute security at all times.',
                    glowColor: DexColors.success,
                  ),
                  _FeatureCard(
                    title: 'Pro Terminal UI',
                    desc: 'A fully customizable workspace with advanced charting, DOM, and multi-monitor support built directly into the browser.',
                    glowColor: DexColors.accentGlow,
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

class _FeatureCard extends StatefulWidget {
  final String title;
  final String desc;
  final Color glowColor;

  const _FeatureCard({
    required this.title,
    required this.desc,
    required this.glowColor,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -10.0 : 0.0),
        child: NeonContainer(
          isActive: _isHovered,
          glowColor: widget.glowColor,
          borderRadius: 24,
          child: GlassContainer(
            borderRadius: 24,
            blur: 20,
            padding: const EdgeInsets.all(40),
            color: DexColors.surfaceLight.withOpacity(_isHovered ? 0.6 : 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.desc,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: DexColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
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
      padding: EdgeInsets.fromLTRB(wide ? 48 : 24, 80, wide ? 48 : 24, 120),
      child: Center(
        child: Column(
          children: [
            NeonContainer(
              isActive: true,
              glowColor: DexColors.primary,
              borderRadius: 100,
              child: GlowButton(
                label: 'LAUNCH TERMINAL',
                onPressed: () => context.go('/trade'),
                width: wide ? 320 : double.infinity,
              ),
            ),
          ],
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
    return GlassContainer(
      borderRadius: 100,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: DexColors.primary.withOpacity(0.1),
      borderColor: DexColors.primary.withOpacity(0.4),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          color: DexColors.primaryGlow,
        ),
      ),
    );
  }
}
