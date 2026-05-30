import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../widgets/dex_glass_card.dart';
import '../../widgets/ticker_tape.dart';
import '../../widgets/cortex_background.dart';
import '../../widgets/globe_particles.dart';
import '../marketing/marketing_shell.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 960;

    return Scaffold(
      backgroundColor: DexColors.background,
      body: CortexBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(wide: wide),
              _StatsGridSection(wide: wide),
              _CortexSection(wide: wide),
              _ExecutionPipelineSection(wide: wide),
              _ImmutableSecuritySection(wide: wide),
              _MobileProtocolSection(wide: wide),
              _FinalCtaSection(wide: wide),
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
    return Container(
      constraints: const BoxConstraints(minHeight: 800),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Pill(text: 'Alpha Stream: Operational', icon: Icons.memory),
                const SizedBox(height: 40),
                Text(
                  'MIRROR\nLEGENDS.',
                  textAlign: TextAlign.center,
                  style: wide ? DexTypography.displayMassive : DexTypography.displayMedium.copyWith(fontSize: 80),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1),
                const SizedBox(height: 40),
                Text(
                  'Institutional capital flows, now accessible via the CopyHood matching engine.\nStop chasing charts. Execute Alpha.',
                  textAlign: TextAlign.center,
                  style: DexTypography.bodyLarge.copyWith(
                    fontSize: wide ? 24 : 18,
                  ),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 60),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _PrimaryButton('Initialize Terminal', () => context.go('/trade')),
                    _SecondaryButton('View Whitepaper', () {}),
                  ],
                ).animate(delay: 400.ms).fadeIn().scaleXY(begin: 0.9),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const TickerTape(),
          ),
        ],
      ),
    );
  }
}

class _StatsGridSection extends StatelessWidget {
  final bool wide;
  const _StatsGridSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _FeatureCard(
                      icon: Icons.people_alt_outlined,
                      title: '1-CLICK MIRROR',
                      desc: 'Instantly clone the performance of high-frequency Master Nodes. Your capital, their expertise, atomic synchronization.',
                      stat: '14.2ms',
                      statLabel: 'AVG. LATENCY',
                    ),
                  ),
                  if (wide) const SizedBox(width: 32),
                  if (wide) Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _StatBox('ACTIVE ALPHA SEEKERS', '2,842,911', 'Global Terminal Network')),
                            const SizedBox(width: 32),
                            Expanded(child: _StatBox('TOTAL MIRROR VALUE', '\$1.42B', 'Institutional Liquidity')),
                          ],
                        ),
                        const SizedBox(height: 32),
                        DexGlassCard(
                          padding: const EdgeInsets.all(48),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('CROSS-CHAIN MATCHING', style: DexTypography.h2.copyWith(color: DexColors.primary)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Synchronizing liquidity across 14 EVM networks and NASDAQ equity markets in a single atomic feed.',
                                      style: DexTypography.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _CortexSection extends StatelessWidget {
  final bool wide;
  const _CortexSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Pill(text: 'Intelligence Protocol v4.0', icon: Icons.memory),
                    const SizedBox(height: 40),
                    Text('THE ALPHA\nCORTEX.', style: DexTypography.displayLarge),
                    const SizedBox(height: 24),
                    Text(
                      'Our proprietary neural network scans millions of data points to identify the top 0.1% of traders. We don\'t just find winners—we find legends.',
                      style: DexTypography.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (wide) const Expanded(child: SizedBox(height: 500, child: GlobeParticles())),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExecutionPipelineSection extends StatelessWidget {
  final bool wide;
  const _ExecutionPipelineSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXECUTION\nPIPELINE.', style: DexTypography.displayLarge),
              const SizedBox(height: 60),
              DexGlassCard(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PORTFOLIO NET-FLOW', style: DexTypography.label.copyWith(color: DexColors.primary)),
                            Text('\$142,392.44', style: DexTypography.monoHero),
                          ],
                        ),
                        _Pill(text: '+12.4% APR', icon: Icons.trending_up, color: DexColors.success),
                      ],
                    ),
                    const SizedBox(height: 60),
                    // Bar Chart Placeholder
                    Container(height: 200, color: DexColors.primarySurface),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImmutableSecuritySection extends StatelessWidget {
  final bool wide;
  const _ImmutableSecuritySection({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF030307),
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              if (wide) const Expanded(child: SizedBox(height: 500, child: Placeholder())), // Vault3D
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Pill(text: 'Institutional Custody Active', icon: Icons.shield, color: DexColors.success),
                    const SizedBox(height: 40),
                    Text('IMMUTABLE\nSECURITY.', style: DexTypography.displayLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileProtocolSection extends StatelessWidget {
  final bool wide;
  const _MobileProtocolSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DexColors.surface,
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Pill(text: 'Mobile Protocol', icon: Icons.smartphone),
              const SizedBox(height: 40),
              Text('ALPHA IN YOUR\nPOCKET.', textAlign: TextAlign.center, style: DexTypography.displayLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  final bool wide;
  const _FinalCtaSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 240, horizontal: 24),
      child: Column(
        children: [
          Text('STOP TRADING.\nSTART MIRRORING.', textAlign: TextAlign.center, style: wide ? DexTypography.displayMassive : DexTypography.displayLarge),
          const SizedBox(height: 60),
          _PrimaryButton('CLAIM ACCESS', () => context.go('/trade')),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  
  const _Pill({required this.text, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? DexColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: themeColor),
          const SizedBox(width: 12),
          Text(text, style: DexTypography.label.copyWith(color: themeColor)),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        decoration: BoxDecoration(
          color: DexColors.primary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(color: DexColors.primary.withValues(alpha: 0.4), blurRadius: 40),
          ],
        ),
        child: Text(label, style: DexTypography.buttonLarge.copyWith(color: Colors.black)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label, style: DexTypography.buttonLarge.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String stat;
  final String statLabel;

  const _FeatureCard({required this.icon, required this.title, required this.desc, required this.stat, required this.statLabel});

  @override
  Widget build(BuildContext context) {
    return DexGlassCard(
      padding: const EdgeInsets.all(40),
      hasGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 40),
          Text(title, style: DexTypography.h2),
          const SizedBox(height: 24),
          Text(desc, style: DexTypography.bodyLarge),
          const SizedBox(height: 40),
          Text(statLabel, style: DexTypography.label.copyWith(color: DexColors.primary)),
          Text(stat, style: DexTypography.monoLarge),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String val;
  final String sub;
  const _StatBox(this.label, this.val, this.sub);

  @override
  Widget build(BuildContext context) {
    return DexGlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DexTypography.label),
          const SizedBox(height: 40),
          Text(val, style: DexTypography.monoHero),
          Text(sub, style: DexTypography.label.copyWith(color: DexColors.primary)),
        ],
      ),
    );
  }
}
