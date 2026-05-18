import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/animated_mesh_gradient.dart';
import 'marketing_shell.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _isYearly = false;
  int _expandedFaq = -1;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedMeshGradient(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120),
              _buildHero(isDesktop),
              _buildPricingCards(isDesktop),
              _buildComparisonTable(isDesktop),
              _buildFAQ(isDesktop),
              _buildCTA(isDesktop),
              const MarketingFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: isDesktop ? 64 : 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Text(
                'TRANSPARENT PRICING',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.primaryGlow,
                ),
              ).animate().fade().slideY(begin: 0.1),
              const SizedBox(height: 16),
              Text(
                'Scale Without\nSurprise Costs',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 80 : 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.05,
                  letterSpacing: -3,
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              Text(
                'Transparent pricing for every investor. Scale as you grow with no hidden fees.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: DexColors.textSecondary,
                ),
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 32),
              // Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggle('Monthly', !_isYearly),
                    _buildToggle('Yearly', _isYearly, badge: '20% OFF'),
                  ],
                ),
              ).animate().fade(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool active, {String? badge}) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = label == 'Yearly'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: active
              ? DexColors.primary.withOpacity(0.12)
              : Colors.transparent,
          border: active
              ? Border.all(color: DexColors.primary.withOpacity(0.2))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? DexColors.primary : Colors.white38,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: DexColors.success.withOpacity(0.15),
                  border: Border.all(color: DexColors.success.withOpacity(0.3)),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: DexColors.success,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCards(bool isDesktop) {
    final tiers = [
      _Tier(
        name: 'Node',
        tagline: 'For individuals exploring crypto',
        monthlyPrice: 0,
        yearlyPrice: 0,
        color: Colors.white54,
        features: [
          'Trade 50+ cryptocurrencies',
          'Standard fees (0.8%)',
          'Basic wallet security',
          'Mobile & desktop access',
          'Email support',
          'Market analysis tools',
          'Real-time price alerts',
        ],
        highlighted: false,
      ),
      _Tier(
        name: 'Vault',
        tagline: 'Advanced tools for serious traders',
        monthlyPrice: 29,
        yearlyPrice: 23,
        color: DexColors.primary,
        features: [
          'Everything in Node, plus:',
          'Reduced fees (0.4%)',
          'Priority execution',
          'Advanced charting',
          'Portfolio analytics',
          'Copy trading access',
          'API access for automation',
          'Priority support (2h)',
        ],
        highlighted: true,
      ),
      _Tier(
        name: 'Sovereign',
        tagline: 'Built for institutions and HFT',
        monthlyPrice: 99,
        yearlyPrice: 79,
        color: DexColors.accent,
        features: [
          'Everything in Vault, plus:',
          'Ultra-low fees (0.1%)',
          'Dedicated account manager',
          'OTC desk for large orders',
          'White-label solutions',
          'Custom API limits (10K/s)',
          'Multi-user team accounts',
          '24/7 phone support',
        ],
        highlighted: false,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 32,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tiers
                      .asMap()
                      .entries
                      .map(
                        (e) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildTierCard(e.value, isDesktop)
                                .animate()
                                .fade(
                                  delay: Duration(
                                    milliseconds: 100 + e.key * 120,
                                  ),
                                )
                                .slideY(begin: 0.05),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: tiers
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTierCard(e.value, isDesktop)
                              .animate()
                              .fade(
                                delay: Duration(
                                  milliseconds: 100 + e.key * 120,
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

  Widget _buildTierCard(_Tier tier, bool isDesktop) {
    final price = _isYearly ? tier.yearlyPrice : tier.monthlyPrice;

    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 24,
      borderColor: tier.highlighted ? DexColors.primary.withOpacity(0.5) : Colors.white.withOpacity(0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tier.name.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: tier.color,
                  letterSpacing: 2,
                ),
              ),
              if (tier.highlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: DexColors.primary.withOpacity(0.15),
                    border: Border.all(
                      color: DexColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'POPULAR',
                    style: GoogleFonts.orbitron(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: DexColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tier.tagline,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price == 0 ? 'Free' : '\$$price',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              if (price > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '/month',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.white30,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          GlowButton(
            label: price == 0 ? 'GET STARTED FREE' : 'START TRADING',
            onPressed: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 20),
          ...tier.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: tier.color.withOpacity(0.6),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: Colors.white54,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(bool isDesktop) {
    if (!isDesktop)
      return const SizedBox.shrink(); // Skip on mobile for readability

    final rows = [
      ('Execution Latency', 'Dextrade: 14ms', 'CEX avg: 200ms', 'DEX avg: 2s'),
      ('Custody', 'MPC Cold Vault', 'Centralized', 'Self-custody'),
      ('Fees', 'From 0.1%', '0.1–0.5%', '0.3% + gas'),
      ('Copy Trading', '✓ Built-in', '✓ Limited', '✗'),
      ('API Access', '10K req/s', '1K req/s', 'On-chain only'),
      ('KYC Required', 'Tiered', 'Always', 'Never'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'HOW WE COMPARE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.accent,
                ),
              ),
              const SizedBox(height: 32),
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.03),
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: SizedBox()),
                    ...[
                      ('Dextrade', DexColors.primary),
                      ('Traditional CEX', Colors.white38),
                      ('DEX / DeFi', Colors.white38),
                    ].map(
                      (h) => Expanded(
                        flex: 2,
                        child: Text(
                          h.$1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: h.$2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ...rows.asMap().entries.map((e) {
                final r = e.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
                    ),
                    color: e.key.isEven ? Colors.white.withOpacity(0.01) : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          r.$1,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          r.$2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DexColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          r.$3,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          r.$4,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQ(bool isDesktop) {
    final faqs = [
      (
        'What is Dextrade?',
        'Dextrade is an institutional-grade liquidity protocol providing direct matching engine access with sub-15ms execution, cold custody, and algorithmic copy trading.',
      ),
      (
        'Is Dextrade secure?',
        'Yes. We use multi-party computation (MPC) vaults with air-gapped signing ceremonies, hardware security modules, and threshold cryptography. Your assets are never held in hot wallets.',
      ),
      (
        'What are the trading fees?',
        'Fees start at 0.8% for Node (free) users and go as low as 0.1% for Sovereign tier. No hidden fees, no surprise charges.',
      ),
      (
        'How does copy trading work?',
        'Our Mirror Protocol algorithmically follows top-tier traders with configurable risk parameters, auto-rebalancing, and real-time position mirroring across futures and spot.',
      ),
      (
        'Do I need KYC?',
        'Basic trading is available immediately. Higher withdrawal limits and advanced features require tiered identity verification.',
      ),
      (
        'Is there an API?',
        'Yes. We provide REST and WebSocket APIs with up to 10,000 requests/second for Sovereign tier users, perfect for algorithmic and HFT strategies.',
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
                'FAQ',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.primaryGlow,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Questions, Answered',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              ...faqs.asMap().entries.map((e) {
                final isExpanded = _expandedFaq == e.key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _expandedFaq = isExpanded ? -1 : e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isExpanded
                          ? DexColors.primary.withOpacity(0.05)
                          : Colors.white.withOpacity(0.02),
                      border: Border.all(
                        color: isExpanded
                            ? DexColors.primary.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.value.$1,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: isExpanded ? 0.125 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.add_rounded,
                                color: isExpanded
                                    ? DexColors.primary
                                    : Colors.white30,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              e.value.$2,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                color: DexColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(
                  delay: Duration(milliseconds: 50 + e.key * 60),
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
                'Start Trading Today',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 40 : 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No credit card required. Free tier available forever.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: DexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              GlowButton(
                label: 'CREATE FREE ACCOUNT',
                onPressed: () {},
                width: isDesktop ? 260 : double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tier {
  final String name, tagline;
  final int monthlyPrice, yearlyPrice;
  final Color color;
  final List<String> features;
  final bool highlighted;
  const _Tier({
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.color,
    required this.features,
    required this.highlighted,
  });
}
