import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/pulse_dot.dart';
import 'marketing_shell.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0;
  final _tabs = ['Trade Engine', 'Copy Protocol', 'Cold Custody'];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),
            _buildHero(isDesktop),
            _buildTabbedShowcase(isDesktop),
            _buildBentoGrid(isDesktop),
            _buildSecuritySection(isDesktop),
            _buildTechSpecs(isDesktop),
            _buildCTABanner(isDesktop),
            const MarketingFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool isDesktop) {
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: DexColors.primary.withOpacity(0.08),
                  border: Border.all(
                    color: DexColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  '⚡ CORE INFRASTRUCTURE',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: DexColors.primary,
                    letterSpacing: 2,
                  ),
                ),
              ).animate().fade().slideY(begin: 0.1),
              const SizedBox(height: 24),
              Text(
                'Built for\nInstitutional Speed',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 64 : 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
              Text(
                'Every component of the Dextrade stack is purpose-built for high-frequency execution, cold custody, and zero-slippage algorithmic routing.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 17 : 15,
                  color: DexColors.textSecondary,
                  height: 1.6,
                ),
              ).animate().fade(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabbedShowcase(bool isDesktop) {
    final contents = [
      _TabContent(
        title: 'Microsecond Matching Engine',
        desc:
            'Direct market access with sub-15ms execution latency. Our proprietary order book aggregation engine routes orders across 14 liquidity venues simultaneously, guaranteeing best execution with zero slippage on orders up to \$5M.',
        stats: {'Latency': '14.2ms', 'Venues': '14', 'Fill Rate': '99.8%'},
        icon: Icons.speed_rounded,
        color: DexColors.primary,
      ),
      _TabContent(
        title: 'Mirror Copy Protocol',
        desc:
            'Institutional-grade copy trading with position mirroring across futures, spot, and options. Algorithmically follows top-tier traders with configurable risk parameters, auto-rebalancing, and cryptographic position verification.',
        stats: {'Top Traders': '240+', 'Avg ROI': '34.2%', 'Sync': 'Real-time'},
        icon: Icons.people_alt_rounded,
        color: DexColors.accent,
      ),
      _TabContent(
        title: 'MPC Cold Custody',
        desc:
            'Multi-party computation vault with air-gapped signing ceremonies. Assets are distributed across geographically isolated hardware security modules with threshold cryptography — no single point of compromise.',
        stats: {'Protected': '\$1.42B', 'Uptime': '100%', 'Audits': '12'},
        icon: Icons.shield_rounded,
        color: DexColors.success,
      ),
    ];

    final content = contents[_activeTab];

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
              // Tab buttons
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
                  children: List.generate(_tabs.length, (i) {
                    final active = i == _activeTab;
                    return Expanded(
                      flex: isDesktop ? 0 : 1,
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 28 : 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: active
                                ? DexColors.primary.withOpacity(0.12)
                                : Colors.transparent,
                            border: active
                                ? Border.all(
                                    color: DexColors.primary.withOpacity(0.2),
                                  )
                                : null,
                          ),
                          child: Text(
                            _tabs[i],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: isDesktop ? 13 : 11,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: active
                                  ? DexColors.primary
                                  : Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 40),
              // Content card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: GlassCard(
                  key: ValueKey(_activeTab),
                  padding: EdgeInsets.all(isDesktop ? 40 : 24),
                  borderRadius: 24,
                  borderColor: content.color.withOpacity(0.12),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTabContentBody(content, isDesktop),
                            ),
                            const SizedBox(width: 40),
                            Expanded(flex: 2, child: _buildTabStats(content)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildTabContentBody(content, isDesktop),
                            const SizedBox(height: 24),
                            _buildTabStats(content),
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

  Widget _buildTabContentBody(_TabContent content, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: content.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: content.color.withOpacity(0.15)),
          ),
          child: Icon(content.icon, color: content.color, size: 24),
        ),
        const SizedBox(height: 20),
        Text(
          content.title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: isDesktop ? 28 : 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content.desc,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: DexColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildTabStats(_TabContent content) {
    return Column(
      children: content.stats.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.02),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                e.key.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.white30,
                  letterSpacing: 1,
                ),
              ),
              Text(
                e.value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: content.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBentoGrid(bool isDesktop) {
    final items = [
      _BentoItem(
        icon: Icons.flash_on_rounded,
        title: 'Zero-Slippage Routing',
        desc: 'Smart order routing across 14 venues guarantees best execution.',
        color: DexColors.primary,
        large: true,
      ),
      _BentoItem(
        icon: Icons.lock_rounded,
        title: 'Passkey Signing',
        desc: 'Biometric authentication with hardware-level cryptography.',
        color: DexColors.accent,
        large: false,
      ),
      _BentoItem(
        icon: Icons.bar_chart_rounded,
        title: 'Real-Time Analytics',
        desc: 'Live P&L tracking, position heat maps, and risk dashboards.',
        color: DexColors.warning,
        large: false,
      ),
      _BentoItem(
        icon: Icons.swap_horiz_rounded,
        title: 'Cross-Margin Engine',
        desc:
            'Unified margin across spot, futures, and options with portfolio-level risk.',
        color: DexColors.success,
        large: true,
      ),
      _BentoItem(
        icon: Icons.api_rounded,
        title: 'REST & WebSocket API',
        desc: 'Full programmatic access for algorithmic strategies.',
        color: DexColors.info,
        large: false,
      ),
      _BentoItem(
        icon: Icons.notifications_active_rounded,
        title: 'Smart Alerts',
        desc:
            'Price triggers, liquidation warnings, and position notifications.',
        color: DexColors.error,
        large: false,
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
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'WHY DEXTRADE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.primaryGlow,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Every Edge, Engineered',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 42 : 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 48),
              // Bento grid
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final i = entry.key;
                  final width = isDesktop
                      ? (item.large ? 580.0 : 280.0)
                      : double.infinity;
                  return SizedBox(
                    width: width,
                    child: _buildBentoCard(item)
                        .animate()
                        .fade(delay: Duration(milliseconds: 100 + i * 80))
                        .slideY(begin: 0.05),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard(_BentoItem item) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 20,
      borderColor: item.color.withOpacity(0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.color.withOpacity(0.15)),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.desc,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: DexColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GlassCard(
            padding: EdgeInsets.all(isDesktop ? 48 : 28),
            borderRadius: 28,
            borderColor: DexColors.success.withOpacity(0.1),
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(flex: 3, child: _buildSecurityLeft(isDesktop)),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: _buildSecurityRight()),
                    ],
                  )
                : Column(
                    children: [
                      _buildSecurityLeft(isDesktop),
                      const SizedBox(height: 32),
                      _buildSecurityRight(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityLeft(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SECURITY INFRASTRUCTURE',
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: DexColors.success,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Secure by Design.\nNot by Afterthought.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: isDesktop ? 36 : 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your funds are completely under your control and secured by biometrics. No one else can touch them — not even us.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: DexColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityRight() {
    final features = [
      (
        'Onchain Smart Wallets',
        'Funds stored in smart contracts on-chain at all times.',
      ),
      ('Passkey-Based Signing', 'Hardware-level biometric authentication.'),
      ('Hardware Wallet Support', 'Connect Ledger or Trezor for signing.'),
      ('Account Recovery', 'Social recovery with trusted guardians.'),
    ];

    return Column(
      children: features.map((f) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.02),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: DexColors.success.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: DexColors.success,
                  size: 16,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.$1,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f.$2,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTechSpecs(bool isDesktop) {
    final specs = [
      (
        'Order Types',
        '12+',
        'Market, Limit, Stop, OCO, Trailing, TWAP, Iceberg...',
      ),
      (
        'Supported Assets',
        '200+',
        'BTC, ETH, SOL, AVAX, LINK and 195 more pairs',
      ),
      ('Max Leverage', '125×', 'Cross-margin and isolated margin modes'),
      (
        'API Rate Limit',
        '10K/s',
        'Enterprise-grade throughput for HFT strategies',
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
          child: Column(
            children: [
              Text(
                'TECHNICAL SPECIFICATIONS',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.accent,
                ),
              ),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isDesktop ? 1.2 : 1.0,
                children: specs.map((s) {
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.$1.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white30,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          s.$2,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          s.$3,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: Colors.white30,
                            height: 1.3,
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

  Widget _buildCTABanner(bool isDesktop) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 48,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.all(isDesktop ? 64 : 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DexColors.primary.withOpacity(0.15),
                DexColors.primaryDark.withOpacity(0.08),
                Colors.transparent,
              ],
            ),
            border: Border.all(color: DexColors.primary.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              Text(
                'Ready to Trade\nLike an Institution?',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 48 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Join thousands of traders who chose sovereign performance.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: DexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              GlowButton(
                label: 'CREATE FREE ACCOUNT',
                onPressed: () {},
                width: isDesktop ? 280 : double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabContent {
  final String title, desc;
  final Map<String, String> stats;
  final IconData icon;
  final Color color;
  const _TabContent({
    required this.title,
    required this.desc,
    required this.stats,
    required this.icon,
    required this.color,
  });
}

class _BentoItem {
  final IconData icon;
  final String title, desc;
  final Color color;
  final bool large;
  const _BentoItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.large,
  });
}
