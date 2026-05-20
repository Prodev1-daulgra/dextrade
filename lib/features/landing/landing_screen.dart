import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/smooth_scroll_wrapper.dart';
import '../../widgets/animated_mesh_gradient.dart';

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
      body: AnimatedMeshGradient(
        child: SmoothScrollWrapper(
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
        // Premium Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              colors: [
                DexColors.primary.withValues(alpha: 0.15),
                DexColors.accent.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: DexColors.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: DexColors.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: -5,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: DexColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DexColors.primary.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'NEXT-GEN INSTITUTIONAL LIQUIDITY',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: DexColors.primary,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ).animate().fade().slideY(begin: 0.2, curve: Curves.easeOutCirc),
        const SizedBox(height: 40),
        
        // Hero Typography
        Text(
          'Trade with',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.spaceGrotesk(
            fontSize: isMobile ? 56 : 96,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
            letterSpacing: -3.0,
          ),
        ).animate().fade(delay: 100.ms).slideX(begin: -0.05),
        
        // Gradient Text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, DexColors.primaryGlow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Sovereign Authority.',
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.spaceGrotesk(
              fontSize: isMobile ? 56 : 96,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
              letterSpacing: -3.0,
            ),
          ),
        ).animate().fade(delay: 150.ms).slideX(begin: -0.05),
        
        const SizedBox(height: 32),
        
        // Subtitle
        Text(
          'Direct matching engine access. Sub-14ms execution latency.\nMathematically verifiable cold custody with zero front-running.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.w400,
            color: DexColors.textSecondary,
            height: 1.6,
            letterSpacing: -0.2,
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 56),
        
        // CTAs
        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            GlowButton(
              label: 'LAUNCH TERMINAL',
              icon: Icons.rocket_launch_rounded,
              onPressed: () => context.push('/register'),
              width: isMobile ? null : 260,
            ),
            const SizedBox(width: 24),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.push('/features'),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'VIEW DEMO',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
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
        ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
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
          // Increased sensitivity for a more dynamic 3D feel
          setState(() {
            _consoleTiltX = (e.position.dy - h / 2) / (h / 2) * -0.12;
            _consoleTiltY = (e.position.dx - w / 2) / (w / 2) * 0.12;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCirc,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_consoleTiltX)
          ..rotateY(_consoleTiltY)
          ..scale(_isConsoleHovered ? 1.05 : 1.0),
        transformAlignment: FractionalOffset.center,
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 32,
          blurAmount: 40, // Extreme frost
          borderColor: DexColors.primary.withValues(alpha: 0.3),
          child: Container(
            height: isMobile ? 350 : 550,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  DexColors.primary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Abstract Grid Pattern inside the console
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: _GridPainter(),
                    ),
                  ),
                ),
                // Simulated Chart Lines
                Positioned.fill(
                  child: CustomPaint(painter: _MockChartPainter()),
                ),
                // Central Glowing Orb for depth
                Positioned(
                  top: 100,
                  right: 50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DexColors.primary.withValues(alpha: 0.2),
                          blurRadius: 100,
                        )
                      ],
                    ),
                  ),
                ),
                // Overlay HUD Top Left
                Positioned(
                  top: 32,
                  left: 32,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: DexColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: DexColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: DexColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: DexColors.success.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MAINNET',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: DexColors.success,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Overlay HUD Bottom Right
                Positioned(
                  bottom: 32,
                  right: 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LATENCY / ROUTING',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          color: Colors.white54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '12.4ms',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: DexColors.primary,
                          shadows: [
                            Shadow(
                              color: DexColors.primary.withValues(alpha: 0.5),
                              blurRadius: 20,
                            )
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
                // Mock Orderbook Side Panel
                Positioned(
                  right: 32,
                  top: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(5, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text(
                              (0.4532 - (i * 0.0011)).toStringAsFixed(4),
                              style: GoogleFonts.jetBrainsMono(
                                color: DexColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              (12.4 + (i * 2.1)).toStringAsFixed(1),
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: 400.ms).slideX(begin: 0.1, curve: Curves.easeOutCirc);
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
        vertical: 120,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: DexColors.primary.withValues(alpha: 0.2)),
                  color: DexColors.primary.withValues(alpha: 0.05),
                ),
                child: Text(
                  'THE DEXTRADE EDGE',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: DexColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Institutional Tooling.\nZero Compromises.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 56 : 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Built for high-frequency traders, engineered for sovereign security.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 18 : 16,
                  color: DexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 80),
              
              // Bento Grid
              if (isDesktop)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildBentoCard(
                            'Cold Custody MPC Vaults',
                            'Geographically distributed signing nodes. Your keys never touch hot storage. Mathematical certainty built-in.',
                            Icons.shield_outlined,
                            DexColors.success,
                            imagePath: 'assets/images/bento_security_1779065769073.png',
                            height: 380,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildBentoCard(
                            '12.4ms Execution',
                            'Direct engine routing with zero-slippage guarantees.',
                            Icons.bolt_rounded,
                            DexColors.primary,
                            imagePath: 'assets/images/bento_routing_1779065754132.png',
                            height: 380,
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
                            'Volume Discounts',
                            'Maker rebates up to 0.02% for top tier liquidity providers.',
                            Icons.pie_chart_outline_rounded,
                            DexColors.accent,
                            height: 340,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildBentoCard(
                            'Mirror Protocol',
                            'Automated strategy replication with sub-millisecond sync.',
                            Icons.hub_outlined,
                            DexColors.primaryGlow,
                            imagePath: 'assets/images/bento_analytics_1779065784478.png',
                            height: 340,
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
                      Icons.shield_outlined,
                      DexColors.success,
                      imagePath: 'assets/images/bento_security_1779065769073.png',
                    ),
                    const SizedBox(height: 16),
                    _buildBentoCard(
                      '12.4ms Execution',
                      'Zero-slippage matching.',
                      Icons.bolt_rounded,
                      DexColors.primary,
                      imagePath: 'assets/images/bento_routing_1779065754132.png',
                    ),
                    const SizedBox(height: 16),
                    _buildBentoCard(
                      'Volume Discounts',
                      'Maker rebates up to 0.02%.',
                      Icons.pie_chart_outline_rounded,
                      DexColors.accent,
                    ),
                    const SizedBox(height: 16),
                    _buildBentoCard(
                      'Mirror Protocol',
                      'Automated strategy replication.',
                      Icons.hub_outlined,
                      DexColors.primaryGlow,
                      imagePath: 'assets/images/bento_analytics_1779065784478.png',
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
    {String? imagePath, double height = 300}
  ) {
    return SizedBox(
      height: height,
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 32,
        blurAmount: 24,
        borderColor: color.withValues(alpha: 0.2),
        child: Stack(
          children: [
            // Ambient Glow Behind Content
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 100)
                  ]
                ),
              ),
            ),
            if (imagePath != null)
              Positioned(
                right: -20,
                bottom: -20,
                width: 280,
                height: 280,
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20)
                      ]
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: DexColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. How It Works Stepper
  Widget _buildHowItWorks(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 100,
      ),
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
                'Sovereign Integration',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 42 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              if (isDesktop)
                Stack(
                  children: [
                    // Gradient Connecting Timeline line
                    Positioned(
                      top: 45,
                      left: 120,
                      right: 120,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DexColors.success.withOpacity(0.5),
                              DexColors.primaryGlow.withOpacity(0.5),
                              DexColors.primary.withOpacity(0.5),
                              DexColors.warning.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildStepCard(
                            '01',
                            'CREATE IDENTITY',
                            'Register your secure account and complete sovereign verification in minutes.',
                            Icons.person_add_alt_1_rounded,
                            DexColors.success,
                            isDesktop,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildStepCard(
                            '02',
                            'LINK CAPITALS',
                            'Securely connect your institutional custodian or deposit assets directly to cold storage.',
                            Icons.account_balance_wallet_outlined,
                            DexColors.primaryGlow,
                            isDesktop,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildStepCard(
                            '03',
                            'SYNC MIRROR',
                            'Choose to mirror verified master strategies or configure custom API triggers.',
                            Icons.hub_outlined,
                            DexColors.primary,
                            isDesktop,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildStepCard(
                            '04',
                            'SCALE MARGIN',
                            'Monitor latency-optimized real-time yield and safely scale your global margin.',
                            Icons.insights_rounded,
                            DexColors.warning,
                            isDesktop,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildMobileStepCard(
                      '01',
                      'CREATE IDENTITY',
                      'Register your secure account and complete sovereign verification in minutes.',
                      Icons.person_add_alt_1_rounded,
                      DexColors.success,
                    ),
                    _buildMobileStepCard(
                      '02',
                      'LINK CAPITALS',
                      'Securely connect your institutional custodian or deposit assets directly to cold storage.',
                      Icons.account_balance_wallet_outlined,
                      DexColors.primaryGlow,
                    ),
                    _buildMobileStepCard(
                      '03',
                      'SYNC MIRROR',
                      'Choose to mirror verified master strategies or configure custom API triggers.',
                      Icons.hub_outlined,
                      DexColors.primary,
                    ),
                    _buildMobileStepCard(
                      '04',
                      'SCALE MARGIN',
                      'Monitor latency-optimized real-time yield and safely scale your global margin.',
                      Icons.insights_rounded,
                      DexColors.warning,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    String number,
    String title,
    String desc,
    IconData icon,
    Color color,
    bool isDesktop,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing Badge Node
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF07070F),
            border: Border.all(color: color.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        // Step number indicator
        Text(
          'STEP $number',
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        // Glass Card Content
        SizedBox(
          height: 180,
          child: GlassCard(
            borderRadius: 24,
            blurAmount: 20,
            borderColor: color.withOpacity(0.1),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: DexColors.textSecondary,
                      height: 1.5,
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

  Widget _buildMobileStepCard(
    String number,
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator with badge
          Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF07070F),
                  border: Border.all(color: color.withOpacity(0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 2,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withOpacity(0.4), Colors.transparent],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GlassCard(
              borderRadius: 20,
              blurAmount: 15,
              borderColor: color.withOpacity(0.1),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP $number',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: DexColors.textSecondary,
                      height: 1.5,
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

  // 6. Testimonials Carousel
  Widget _buildTestimonials() {
    final tests = [
      (
        'Alex M.',
        'Fund Manager',
        'Dextrade completely eliminated our execution latency issues.',
        DexColors.success,
      ),
      (
        'Sarah K.',
        'Prop Trader',
        'The cross-margin engine is the best in the industry.',
        DexColors.primary,
      ),
      (
        'James R.',
        'Algorithmic Trader',
        'API reliability is unmatched. 10K req/s without a single drop.',
        DexColors.accent,
      ),
      (
        'Elena V.',
        'Copy Trader',
        'Mirror protocol made it so easy to follow the alpha.',
        DexColors.primaryGlow,
      ),
      (
        'David H.',
        'Whale',
        'The MPC vault gives me peace of mind for cold storage.',
        DexColors.warning,
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
            height: 240,
            child: ListView.builder(
              controller: _testimonialController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final t = tests[index % tests.length];
                return _buildTestimonialCard(t.$1, t.$2, t.$3, t.$4);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
    String name,
    String role,
    String quote,
    Color accentColor,
  ) {
    return Container(
      width: 380,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderRadius: 24,
        blurAmount: 20,
        borderColor: accentColor.withOpacity(0.12),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Star rating indicator
                for (int i = 0; i < 5; i++)
                  Icon(
                    Icons.star_rounded,
                    color: DexColors.warning,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                '"$quote"',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accentColor.withOpacity(0.4), accentColor.withOpacity(0.1)],
                    ),
                    border: Border.all(color: accentColor.withOpacity(0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name[0],
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      role,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: DexColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 7. Massive CTA Banner
  Widget _buildMassiveCTA(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GlassCard(
            borderRadius: 32,
            blurAmount: 24,
            borderColor: DexColors.primary.withOpacity(0.18),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 80 : 32,
              vertical: isDesktop ? 80 : 48,
            ),
            child: Stack(
              children: [
                // Top-right glowing radial background
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DexColors.primary.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: DexColors.primary.withOpacity(0.15),
                          blurRadius: 100,
                        )
                      ],
                    ),
                  ),
                ),
                // Left glowing radial background
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DexColors.accent.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: DexColors.accent.withOpacity(0.1),
                          blurRadius: 100,
                        )
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Glowing lightning pill badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: DexColors.primary.withOpacity(0.1),
                        border: Border.all(color: DexColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flash_on, color: DexColors.primary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'UPGRADE PROTOCOL',
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: DexColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Ready to Experience Sovereign Performance?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deploy institutional grade trading and zero-slippage copy systems today.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isDesktop ? 18 : 15,
                        color: DexColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    isDesktop
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GlowButton(
                                label: 'DOWNLOAD ANDROID (APK)',
                                onPressed: () async {
                                  final url = Uri.parse('/app-release.apk');
                                  if (!await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  )) {
                                    debugPrint('Could not launch $url');
                                  }
                                },
                                width: 260,
                              ),
                              const SizedBox(width: 16),
                              _buildSecondaryCTA(context),
                            ],
                          )
                        : Column(
                            children: [
                              GlowButton(
                                label: 'DOWNLOAD ANDROID (APK)',
                                onPressed: () async {
                                  final url = Uri.parse('/app-release.apk');
                                  if (!await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  )) {
                                    debugPrint('Could not launch $url');
                                  }
                                },
                                width: double.infinity,
                              ),
                              const SizedBox(height: 16),
                              _buildSecondaryCTA(context, fullWidth: true),
                            ],
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCTA(BuildContext context, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : 240,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        color: Colors.white.withOpacity(0.02),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apple_rounded, color: Colors.white.withOpacity(0.3), size: 18),
          const SizedBox(width: 8),
          Text(
            'COMING SOON TO iOS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 1.5,
            ),
          ),
        ],
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DexColors.primary.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    const step = 30.0;
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

