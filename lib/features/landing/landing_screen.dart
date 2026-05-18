import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/smooth_scroll_wrapper.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final ScrollController _tapeController;
  late final ScrollController _marqueeController;
  late final ScrollController _testimonialController;

  Timer? _tapeTimer;
  Timer? _marqueeTimer;
  Timer? _testimonialTimer;

  // 3D Parallax Tilt state
  double _consoleTiltX = 0.0;
  double _consoleTiltY = 0.0;
  bool _isConsoleHovered = false;

  final List<Map<String, dynamic>> _mockTrades = [
    {'sym': 'BTC/USDT', 'price': '97,240', 'chg': '+2.4%', 'pos': true},
    {'sym': 'ETH/USDT', 'price': '3,842.50', 'chg': '+1.8%', 'pos': true},
    {'sym': 'SOL/USDT', 'price': '198.12', 'chg': '+5.2%', 'pos': true},
    {'sym': 'AVAX/USDT', 'price': '38.45', 'chg': '+4.1%', 'pos': true},
    {'sym': 'LINK/USDT', 'price': '18.92', 'chg': '-1.5%', 'pos': false},
    {'sym': 'NEAR/USDT', 'price': '7.24', 'chg': '+6.8%', 'pos': true},
    {'sym': 'RENDER/USDT', 'price': '9.82', 'chg': '+8.3%', 'pos': true},
    {'sym': 'SUI/USDT', 'price': '3.14', 'chg': '-2.1%', 'pos': false},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tapeController = ScrollController();
    _marqueeController = ScrollController();
    _testimonialController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(_tapeController, _tapeTimer, 30);
      _startAutoScroll(_marqueeController, _marqueeTimer, 40);
      _startAutoScroll(
        _testimonialController,
        _testimonialTimer,
        50,
        reverse: true,
      );
    });
  }

  void _startAutoScroll(
    ScrollController controller,
    Timer? timer,
    int ms, {
    bool reverse = false,
  }) {
    timer = Timer.periodic(Duration(milliseconds: ms), (timer) {
      if (!controller.hasClients) return;

      final maxScroll = controller.position.maxScrollExtent;
      final currentScroll = controller.offset;

      if (reverse) {
        if (currentScroll <= 0) {
          controller.jumpTo(maxScroll);
        } else {
          controller.jumpTo(currentScroll - 1);
        }
      } else {
        if (currentScroll >= maxScroll) {
          controller.jumpTo(0);
        } else {
          controller.jumpTo(currentScroll + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tapeController.dispose();
    _marqueeController.dispose();
    _testimonialController.dispose();
    _tapeTimer?.cancel();
    _marqueeTimer?.cancel();
    _testimonialTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SmoothScrollWrapper(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 100), // Space for MarketingShell navbar
              _buildHero(isDesktop),
              _buildExecutionTape(),
              _buildTrustMarquee(),
              _buildWhyDextradeBento(isDesktop),
              _buildHowItWorks(isDesktop),
              _buildTestimonials(),
              _buildMassiveCTA(isDesktop),
              // Footer is provided by MarketingShell wrapper in router
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Hero — Split: editorial mega-typography LEFT + interactive 3D console RIGHT
  Widget _buildHero(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(flex: 11, child: _buildHeroLeft()),
                    const SizedBox(width: 60),
                    Expanded(flex: 10, child: _buildPerspectiveConsole()),
                  ],
                )
              : Column(
                  children: [
                    _buildHeroLeft(isMobile: true),
                    const SizedBox(height: 64),
                    _buildPerspectiveConsole(isMobile: true),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroLeft({bool isMobile = false}) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: DexColors.primary.withOpacity(0.08),
            border: Border.all(color: DexColors.primary.withOpacity(0.15)),
          ),
          child: Text(
            'INSTITUTIONAL LIQUIDITY PROTOCOL',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: DexColors.primary,
              letterSpacing: 2,
            ),
          ),
        ).animate().fade().slideY(begin: 0.1),
        const SizedBox(height: 32),
        Text(
          'Trade with Sovereign Authority.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.spaceGrotesk(
            fontSize: isMobile ? 48 : 82,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
            letterSpacing: -2.5,
          ),
        ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        Text(
          'Direct matching engine access, sub-15ms execution latency, and mathematically verifiable cold custody. No front-running. No slippage cascades.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.spaceGrotesk(
            fontSize: isMobile ? 16 : 18,
            color: DexColors.textSecondary,
            height: 1.6,
          ),
        ).animate().fade(delay: 200.ms),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            GlowButton(
              label: 'LAUNCH TERMINAL',
              onPressed: () => context.push('/register'),
              width: 220,
              height: 56,
            ),
            const SizedBox(width: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/features'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    color: Colors.white.withOpacity(0.02),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'HOW IT WORKS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fade(delay: 300.ms),
      ],
    );
  }

  Widget _buildPerspectiveConsole({bool isMobile = false}) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isConsoleHovered = true),
      onExit: (_) => setState(() {
        _isConsoleHovered = false;
        _consoleTiltX = 0;
        _consoleTiltY = 0;
      }),
      onHover: (e) {
        if (!isMobile) {
          final w = MediaQuery.of(context).size.width;
          final h = MediaQuery.of(context).size.height;
          setState(() {
            _consoleTiltX = (e.position.dy - h / 2) / (h / 2) * -0.05;
            _consoleTiltY = (e.position.dx - w / 2) / (w / 2) * 0.05;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_consoleTiltX)
          ..rotateY(_consoleTiltY),
        transformAlignment: FractionalOffset.center,
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          borderColor: DexColors.primary.withOpacity(0.2),
          child: Container(
            height: isMobile ? 300 : 450,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  DexColors.primary.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Simulated Chart Lines
                Positioned.fill(
                  child: CustomPaint(painter: _MockChartPainter()),
                ),
                // Overlay HUD
                Positioned(
                  top: 24,
                  left: 24,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: DexColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: DexColors.success.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: DexColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: DexColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'BTC/USD  97,240.50',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LATENCY',
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          color: Colors.white30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '14.2ms',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: DexColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: 400.ms).slideX(begin: 0.1);
  }

  // 2. Trust Bar — Logo marquee
  Widget _buildTrustMarquee() {
    final partners = [
      'Binance',
      'Coinbase',
      'Kraken',
      'Paradigm',
      'a16z',
      'Sequoia',
      'Wintermute',
      'Jump Crypto',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.03)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TRUSTED BY INDUSTRY LEADERS',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 40,
            child: ListView.builder(
              controller: _marqueeController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final text = partners[index % partners.length];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    text.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.15),
                      letterSpacing: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. Live Ticker Tape
  Widget _buildExecutionTape() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: DexColors.primary.withOpacity(0.05),
        border: Border.symmetric(
          horizontal: BorderSide(color: DexColors.primary.withOpacity(0.1)),
        ),
      ),
      child: ListView.builder(
        controller: _tapeController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final trade = _mockTrades[index % _mockTrades.length];
          final pos = trade['pos'] as bool;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trade['sym'],
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${trade['price']}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  trade['chg'],
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: pos ? DexColors.success : DexColors.error,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Why Dextrade Bento Grid (4 asymmetric cards)
  Widget _buildWhyDextradeBento(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'THE DEXTRADE EDGE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Institutional Tooling.\nZero Compromises.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 48 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 60),
              if (isDesktop)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildBentoCard(
                            'Cold Custody MPC Vaults',
                            'Geographically distributed signing nodes.',
                            Icons.shield,
                            DexColors.success,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildBentoCard(
                            '14ms Execution',
                            'Zero-slippage matching.',
                            Icons.speed,
                            DexColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildBentoCard(
                            '0.1% Max Fees',
                            'Tiered volume discounts.',
                            Icons.account_balance_wallet,
                            DexColors.warning,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildBentoCard(
                            'Mirror Protocol',
                            'Automated strategy replication.',
                            Icons.people,
                            DexColors.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildBentoCard(
                      'Cold Custody MPC Vaults',
                      'Geographically distributed signing nodes.',
                      Icons.shield,
                      DexColors.success,
                    ),
                    const SizedBox(height: 16),
                    _buildBentoCard(
                      '14ms Execution',
                      'Zero-slippage matching.',
                      Icons.speed,
                      DexColors.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildBentoCard(
                      '0.1% Max Fees',
                      'Tiered volume discounts.',
                      Icons.account_balance_wallet,
                      DexColors.warning,
                    ),
                    const SizedBox(height: 16),
                    _buildBentoCard(
                      'Mirror Protocol',
                      'Automated strategy replication.',
                      Icons.people,
                      DexColors.info,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard(
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: 24,
      borderColor: color.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: DexColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 5. How It Works Stepper
  Widget _buildHowItWorks(bool isDesktop) {
    final steps = [
      ('1. Create Account', 'Sign up and verify your identity in minutes.'),
      ('2. Fund Wallet', 'Deposit crypto or fiat securely.'),
      ('3. Trade or Copy', 'Execute manually or follow top traders.'),
      ('4. Scale Portfolio', 'Analyze performance and scale margin.'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 80,
      ),
      color: Colors.white.withOpacity(0.01),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'ONBOARDING',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'From Zero to Alpha',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 42 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: steps
                          .map(
                            (s) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.$1,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      s.$2,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        color: DexColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Column(
                      children: steps
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.$1,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.$2,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15,
                                      color: DexColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // 6. Testimonials Carousel
  Widget _buildTestimonials() {
    final tests = [
      (
        'Alex M.',
        'Fund Manager',
        'Dextrade completely eliminated our execution latency issues.',
      ),
      (
        'Sarah K.',
        'Prop Trader',
        'The cross-margin engine is the best in the industry.',
      ),
      (
        'James R.',
        'Algorithmic Trader',
        'API reliability is unmatched. 10K req/s without a single drop.',
      ),
      (
        'Elena V.',
        'Copy Trader',
        'Mirror protocol made it so easy to follow the alpha.',
      ),
      (
        'David H.',
        'Whale',
        'The MPC vault gives me peace of mind for cold storage.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Text(
            'TESTIMONIALS',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: DexColors.success,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loved by Professionals',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 200,
            child: ListView.builder(
              controller: _testimonialController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final t = tests[index % tests.length];
                return Container(
                  width: 350,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.02),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: DexColors.primary.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                t.$1[0],
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w800,
                                  color: DexColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.$1,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                t.$2,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: DexColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '"${t.$3}"',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 7. Massive CTA Banner
  Widget _buildMassiveCTA(bool isDesktop) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.all(isDesktop ? 80 : 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DexColors.primary.withOpacity(0.2),
                DexColors.primaryDark.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            border: Border.all(color: DexColors.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Text(
                'Ready to Upgrade?',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 56 : 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create your free account today and experience sovereign performance.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 18 : 16,
                  color: DexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlowButton(
                          label: 'OPEN FREE ACCOUNT',
                          onPressed: () => context.push('/register'),
                          width: 240,
                        ),
                        const SizedBox(width: 16),
                        _buildSecondaryCTA(context),
                      ],
                    )
                  : Column(
                      children: [
                        GlowButton(
                          label: 'OPEN FREE ACCOUNT',
                          onPressed: () => context.push('/register'),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),
                        _buildSecondaryCTA(context, fullWidth: true),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCTA(BuildContext context, {bool fullWidth = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/pricing'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: fullWidth ? double.infinity : 200,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Center(
            child: Text(
              'VIEW PRICING',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Simple Chart Painter for the 3D Console ───
class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DexColors.primary.withOpacity(0.4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    final points = [
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.1),
      Offset(size.width, size.height * 0.05),
    ];

    for (var p in points) {
      path.lineTo(p.dx, p.dy);
    }

    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = DexColors.primary.withOpacity(0.2)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
