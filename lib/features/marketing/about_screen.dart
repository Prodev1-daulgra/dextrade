import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import 'design/marketing_page_scaffold.dart';
import 'design/marketing_download_cta.dart';
import 'marketing_shell.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return MarketingPageScaffold(
      showFooter: false,
      children: [
        _buildManifesto(isDesktop),
        _buildGlobalPresence(isDesktop),
        _buildMissionCards(isDesktop),
        _buildStats(isDesktop),
        _buildTeamGrid(isDesktop),
        _buildComplianceBadges(isDesktop),
        _buildTimeline(isDesktop),
        _buildCTA(isDesktop),
        const MarketingDownloadCta(),
        const MarketingFooter(),
      ],
    );
  }

  Widget _buildManifesto(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: isDesktop ? 80 : 48,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Text(
                'OUR MANIFESTO',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.primaryGlow,
                ),
              ).animate().fade().slideY(begin: 0.1),
              const SizedBox(height: 24),
              Text(
                'Democratizing\nInstitutional Finance',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 80 : 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -3,
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
              Text(
                'We believe every trader deserves the same infrastructure that powers Wall Street. Dextrade was built to eliminate the execution gap between retail and institutional trading — giving sovereign performance to everyone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 17 : 15,
                  color: DexColors.textSecondary,
                  height: 1.7,
                ),
              ).animate().fade(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalPresence(bool isDesktop) {
    return Container(
      width: double.infinity,
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radar sweep
              Positioned.fill(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 4),
                  builder: (context, val, child) {
                    return Transform.rotate(
                      angle: val * 2 * 3.14159,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.transparent,
                              DexColors.primary.withOpacity(0.05),
                              DexColors.primary.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.8, 1.0, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Map placeholder dots
              ...List.generate(12, (index) {
                return Positioned(
                  left: 200 + (index * 45.0) % 600,
                  top: 100 + (index * 60.0) % 200,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: DexColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DexColors.primary.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat()).fade(duration: 1000.ms, begin: 0.2, end: 1.0).then().fade(duration: 1000.ms, begin: 1.0, end: 0.2),
                );
              }),
              Positioned(
                bottom: 20,
                child: Text(
                  '14 GLOBAL LIQUIDITY NODES',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: DexColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionCards(bool isDesktop) {
    final missions = [
      (
        Icons.flash_on_rounded,
        'Speed as a Right',
        'Every millisecond matters. We built our matching engine from scratch in Rust — not bolted onto existing infrastructure.',
        DexColors.primary,
      ),
      (
        Icons.shield_rounded,
        'Security First',
        'Air-gapped MPC vaults, threshold cryptography, and zero-trust architecture. Your keys, your custody.',
        DexColors.success,
      ),
      (
        Icons.equalizer_rounded,
        'Fair Markets',
        'No front-running, no hidden fees, no maker-taker games. Transparent order books with verifiable execution.',
        DexColors.accent,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 48,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  children: missions
                      .asMap()
                      .entries
                      .map(
                        (e) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildMissionCard(e.value, isDesktop)
                                .animate()
                                .fade(
                                  delay: Duration(
                                    milliseconds: 200 + e.key * 100,
                                  ),
                                )
                                .slideY(begin: 0.05),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: missions
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildMissionCard(e.value, isDesktop)
                              .animate()
                              .fade(
                                delay: Duration(
                                  milliseconds: 200 + e.key * 100,
                                ),
                              )
                              .slideY(begin: 0.05),
                        ),
                      )
                      .toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildMissionCard(
    (IconData, String, String, Color) mission,
    bool isDesktop,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 22,
      borderColor: mission.$4.withOpacity(0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mission.$4.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: mission.$4.withOpacity(0.15)),
            ),
            child: Icon(mission.$1, color: mission.$4, size: 22),
          ),
          const SizedBox(height: 20),
          Text(
            mission.$2,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            mission.$3,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: DexColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDesktop) {
    final stats = [
      ('\$1.42B', 'Total Value Protected'),
      ('14.2ms', 'Average Execution'),
      ('99.8%', 'Fill Rate'),
      ('240+', 'Master Traders'),
      ('50K+', 'Active Users'),
      ('12', 'Security Audits'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 56,
      ),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
        color: Colors.white.withOpacity(0.01),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            spacing: isDesktop ? 48 : 24,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: stats.map((s) {
              return SizedBox(
                width: isDesktop ? 160 : 140,
                child: Column(
                  children: [
                    Text(
                      s.$1,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isDesktop ? 36 : 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.$2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white30,
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

  Widget _buildTeamGrid(bool isDesktop) {
    final team = [
      ('Alex Mercer', 'CEO & Co-Founder', 'Ex-Goldman Sachs, 15yr HFT'),
      ('Sarah Chen', 'CTO', 'Ex-Binance Engineering Lead'),
      ('Marcus Webb', 'Head of Security', 'Former NSA Cryptographer'),
      ('Yuki Tanaka', 'Head of Product', 'Ex-Revolut, Stripe'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'LEADERSHIP',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Built by Veterans',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isDesktop ? 0.85 : 0.75,
                children: team.asMap().entries.map((e) {
                  final t = e.value;
                  final initials = t.$1.split(' ').map((w) => w[0]).join();
                  return GlassCard(
                        padding: const EdgeInsets.all(20),
                        borderRadius: 18,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    DexColors.primary.withOpacity(0.2),
                                    DexColors.accent.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: DexColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: DexColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t.$1,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.$2,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: DexColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.$3,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fade(delay: Duration(milliseconds: 100 + e.key * 80))
                      .slideY(begin: 0.05);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceBadges(bool isDesktop) {
    final badges = [
      ('SOC 2 Type II', Icons.verified_user_rounded),
      ('ISO 27001', Icons.policy_rounded),
      ('GDPR Compliant', Icons.privacy_tip_rounded),
      ('PCI DSS', Icons.credit_card_rounded),
      ('Multi-Sig Audit', Icons.security_rounded),
      ('Bug Bounty', Icons.bug_report_rounded),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 48,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'COMPLIANCE & CERTIFICATIONS',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.success,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: badges.map((b) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.02),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(b.$2, color: DexColors.success, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          b.$1,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(bool isDesktop) {
    final events = [
      (
        '2023 Q1',
        'Founded',
        'Dextrade founded by ex-Goldman and ex-Binance engineers.',
      ),
      (
        '2023 Q3',
        'Alpha Launch',
        'Private alpha with 500 institutional traders.',
      ),
      ('2024 Q1', 'Series A', '\$12M raised from Paradigm and a16z.'),
      (
        '2024 Q4',
        'Public Launch',
        'Open access with 50K+ users in first month.',
      ),
      ('2025 Q2', 'SOC 2 Certified', 'Full compliance audit completed.'),
      (
        '2026',
        'Today',
        '\$1.42B in assets under custody. 200+ master traders.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                'OUR JOURNEY',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.primaryGlow,
                ),
              ),
              const SizedBox(height: 40),
              ...events.asMap().entries.map((e) {
                final ev = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline line
                      SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: e.key == events.length - 1
                                    ? DexColors.primary
                                    : Colors.white.withOpacity(0.15),
                                border: Border.all(
                                  color: e.key == events.length - 1
                                      ? DexColors.primary
                                      : Colors.white.withOpacity(0.1),
                                  width: 2,
                                ),
                                boxShadow: e.key == events.length - 1
                                    ? [
                                        BoxShadow(
                                          color: DexColors.primary.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            if (e.key < events.length - 1)
                              Container(
                                width: 1,
                                height: 60,
                                color: Colors.white.withOpacity(0.06),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ev.$1,
                                style: GoogleFonts.orbitron(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: DexColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ev.$2,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ev.$3,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: Colors.white38,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(
                  delay: Duration(milliseconds: 100 + e.key * 80),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTA(bool isDesktop) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 32,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.all(isDesktop ? 56 : 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [DexColors.primary.withOpacity(0.15), Colors.transparent],
            ),
            border: Border.all(color: DexColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                'Join the Movement',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 40 : 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Trade with institutional-grade infrastructure. No compromises.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: DexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [GlowButton(label: 'GET STARTED', onPressed: () {})],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
