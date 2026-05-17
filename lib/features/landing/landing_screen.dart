import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _glowController;
  double _scrollOffset = 0.0;

  // Mock trades for the execution tape
  final List<Map<String, dynamic>> _mockTrades = [
    {'sym': 'BTC/USDT', 'price': '97,240', 'chg': '+2.4%', 'pos': true},
    {'sym': 'ETH/USDT', 'price': '3,842.50', 'chg': '+1.8%', 'pos': true},
    {'sym': 'SOL/USDT', 'price': '198.12', 'chg': '+5.2%', 'pos': true},
    {'sym': 'AAPL', 'price': '224.50', 'chg': '+1.2%', 'pos': true},
    {'sym': 'NVDA', 'price': '145.82', 'chg': '+3.1%', 'pos': true},
    {'sym': 'TSLA', 'price': '342.10', 'chg': '-0.8%', 'pos': false},
    {'sym': 'AVAX/USDT', 'price': '38.45', 'chg': '+4.1%', 'pos': true},
    {'sym': 'LINK/USDT', 'price': '18.92', 'chg': '-1.5%', 'pos': false},
  ];

  late final ScrollController _tapeController;
  Timer? _tapeTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tapeController = ScrollController();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Infinite scroll for the ticker tape
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTapeScroll();
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _startTapeScroll() {
    _tapeTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_tapeController.hasClients) {
        final maxScroll = _tapeController.position.maxScrollExtent;
        final currentScroll = _tapeController.offset;
        if (currentScroll >= maxScroll - 1) {
          _tapeController.jumpTo(0.0);
        } else {
          _tapeController.jumpTo(currentScroll + 1.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _glowController.dispose();
    _tapeController.dispose();
    _tapeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 900;

    return Scaffold(
      backgroundColor: Colors.black, // Obsidian deep pitch black
      body: Stack(
        children: [
          // ─── Ambient Pulsing Glowing Orbs ───
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              final val = _glowController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (val * 100),
                    left: -150 + (val * 120),
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DexColors.primary.withOpacity(0.08 + (val * 0.05)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100 - (val * 80),
                    right: -100 + (val * 150),
                    child: Container(
                      width: 600,
                      height: 600,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DexColors.accent.withOpacity(0.05 + (val * 0.05)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ─── Main Content Scroll View ───
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Spacer for Sticky Navigation Bar
                const SizedBox(height: 100),

                // ─── Hero Section ───
                _buildHeroSection(context, isDesktop),

                // ─── Stats Grid ───
                _buildStatsGrid(isDesktop),

                // ─── Alpha Cortex WebGL Canvas Node Graph ───
                _buildCortexSection(isDesktop),

                // ─── Execution Pipeline Net-Flow & Live Tape ───
                _buildPipelineSection(isDesktop),

                // ─── Vault Custody Section ───
                _buildVaultSection(isDesktop),

                // ─── Footer ───
                _buildFooter(isDesktop),
              ],
            ),
          ),

          // ─── Frosted Floating Glass Navigation Bar ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNavBar(context, isDesktop),
          ),
        ],
      ),
    );
  }

  // ─── Navigation Bar Widget ───
  Widget _buildNavBar(BuildContext context, bool isDesktop) {
    final navOpacity = math.min(1.0, _scrollOffset / 200.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4 * navOpacity),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08 * navOpacity),
            width: 1.0,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withOpacity(0.3 * navOpacity),
            BlendMode.srcOver,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo & Branding
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DexColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: DexColors.primary.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEXTRADE',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'HIGH-PERFORMANCE TERMINAL',
                            style: GoogleFonts.inter(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: DexColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Nav Links (Desktop)
                if (isDesktop)
                  Row(
                    children: [
                      _buildNavLink('Technology'),
                      _buildNavLink('Assets'),
                      _buildNavLink('Security'),
                      _buildNavLink('Institutional'),
                    ],
                  ),

                // Auth Actions
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: Text(
                        'LOG IN',
                        style: DexTypography.button.copyWith(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DexColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ).copyWith(
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: Text(
                        'CLAIM ACCESS',
                        style: DexTypography.button.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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

  Widget _buildNavLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Colors.white60,
        ),
      ),
    );
  }

  // ─── Hero Section ───
  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Operational Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DexColors.success,
                    boxShadow: [
                      BoxShadow(
                        color: DexColors.success,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ALPHA STREAM: OPERATIONAL',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 32),

          // God-Level Heading
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'MIRROR\n',
                  style: GoogleFonts.outfit(
                    fontSize: isDesktop ? 120 : 64,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 0.8,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'LEGENDS.',
                  style: GoogleFonts.outfit(
                    fontSize: isDesktop ? 120 : 64,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 0.8,
                    color: DexColors.primary,
                    shadows: [
                      Shadow(
                        color: DexColors.primary.withOpacity(0.6),
                        blurRadius: 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 200.ms, duration: 800.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut),

          const SizedBox(height: 24),

          // Subtitle description
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Institutional capital flows, now accessible via the Dextrade matching engine. Stop chasing charts. Execute Alpha.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 18 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                height: 1.6,
              ),
            ),
          ).animate().fade(delay: 400.ms, duration: 800.ms),

          const SizedBox(height: 40),

          // Main CTAs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DexColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: DexColors.primary,
                  elevation: 20,
                ),
                child: Text(
                  'INITIALIZE TERMINAL',
                  style: DexTypography.buttonLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VIEW DECK',
                      style: DexTypography.buttonLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ).animate().fade(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 80),

          // Ticker Tape widget
          _buildTickerTape(),
        ],
      ),
    );
  }

  // Infinite Horizontal Ticker Tape
  Widget _buildTickerTape() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: SizedBox(
        height: 35,
        child: ListView.builder(
          controller: _tapeController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final trade = _mockTrades[index % _mockTrades.length];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Text(
                    trade['sym'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\$${trade['price']}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trade['pos']
                          ? DexColors.success.withOpacity(0.1)
                          : DexColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: trade['pos']
                            ? DexColors.success.withOpacity(0.2)
                            : DexColors.error.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      trade['chg'],
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: trade['pos'] ? DexColors.successGlow : DexColors.errorGlow,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Stats Grid ───
  Widget _buildStatsGrid(bool isDesktop) {
    final widgets = [
      _buildGlassCard(
        icon: Icons.flash_on,
        title: '1-CLICK MIRROR',
        desc: 'Instantly clone the performance of high-frequency Master Nodes. Your capital, their expertise, atomic synchronization.',
        statLabel: 'AVG. LATENCY',
        statValue: '14.2ms',
        iconColor: DexColors.primary,
      ),
      _buildGlassCard(
        icon: Icons.trending_up,
        title: 'PROVEN ALPHA',
        desc: 'Observe verified trader ledger indexes. Fully backtested performance metrics mapped directly on-chain for complete transparency.',
        statLabel: 'PLATFORM VALUE',
        statValue: '\$1.42B',
        iconColor: DexColors.accent,
      ),
      _buildGlassCard(
        icon: Icons.shield,
        title: 'ATOMIC SYNC',
        desc: 'Distributed WebSocket feeds deploy capital in perfect synchronization, entirely neutralizing negative slippage windows.',
        statLabel: 'SUCCESS RATE',
        statValue: '99.8%',
        iconColor: DexColors.success,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(
            'ENGINEERING EXCELLENCE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: DexColors.primary,
            ),
          ).animate().fade(duration: 800.ms),
          const SizedBox(height: 16),
          Text(
            'Built for institutional speeds.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ).animate().fade(delay: 100.ms, duration: 800.ms),
          const SizedBox(height: 64),
          if (isDesktop)
            Row(
              children: widgets.map((w) => Expanded(child: Padding(padding: const EdgeInsets.all(12), child: w))).toList(),
            )
          else
            Column(
              children: widgets.map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: w)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required String title,
    required String desc,
    required String statLabel,
    required String statValue,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white38,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statLabel,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statValue,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
                child: const Icon(Icons.arrow_outward, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  // ─── Alpha Cortex Section with Animated Node Graph ───
  Widget _buildCortexSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left features
            Expanded(
              flex: isDesktop ? 6 : 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: DexColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: DexColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.memory, color: DexColors.primary, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'INTELLIGENCE PROTOCOL V4.0',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: DexColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'THE ALPHA\n',
                          style: GoogleFonts.outfit(
                            fontSize: isDesktop ? 64 : 40,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'CORTEX.',
                          style: GoogleFonts.outfit(
                            fontSize: isDesktop ? 64 : 40,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: DexColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Our proprietary matching engine constantly maps live sentiment data feeds, identifying elite risk-mitigation vectors to optimize allocations in real-time.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildCortexFeature(Icons.bubble_chart, 'SENTIMENT MAPPING', 'Global live data node sync.'),
                  const SizedBox(height: 24),
                  _buildCortexFeature(Icons.donut_large, 'PREDICTIVE ROI', 'Algorithmic probabilistic modeling.'),
                  const SizedBox(height: 24),
                  _buildCortexFeature(Icons.gpp_good, 'RISK NEUTRALIZATION', 'Automated leverage controls.'),
                ],
              ),
            ),

            if (isDesktop) const SizedBox(width: 80) else const SizedBox(height: 64),

            // Right Pulsing Custom Node graph
            Expanded(
              flex: isDesktop ? 6 : 0,
              child: Container(
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Stack(
                    children: [
                      // Grid Matrix Background
                      const Positioned.fill(
                        child: GridPainterWidget(),
                      ),
                      // Connecting Pulse Nodes
                      const Positioned.fill(
                        child: AnimatedNodesWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCortexFeature(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: DexColors.primary, size: 20),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Pipeline Section ───
  Widget _buildPipelineSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PORTFOLIO NET-FLOW',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: DexColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Live Pipeline.',
                      style: GoogleFonts.outfit(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: DexColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DexColors.success.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: DexColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE ENGINE',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: DexColors.successGlow,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                    flex: isDesktop ? 7 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MIRROR POOL INDEX',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white30,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$142,392.44',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: isDesktop ? 64 : 40,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Mock Chart representation
                        _buildCustomBarChart(),
                      ],
                    ),
                  ),
                  if (isDesktop) const SizedBox(width: 64) else const SizedBox(height: 64),
                  Expanded(
                    flex: isDesktop ? 5 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER EXECUTION RECORD',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: DexColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTradeRow('BTC/USDT', 'MIRROR_ACQ_942', '\$97,240', '+12.4% APR', true),
                          const Divider(color: Colors.white10, height: 24),
                          _buildTradeRow('ETH/USDT', 'MIRROR_ACQ_104', '\$3,842', '+9.8% APR', true),
                          const Divider(color: Colors.white10, height: 24),
                          _buildTradeRow('SOL/USDT', 'MIRROR_ACQ_802', '\$198', '+15.2% APR', true),
                        ],
                      ),
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

  Widget _buildTradeRow(String sym, String node, String price, String apr, bool pos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sym,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            Text(
              node,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.white30,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              apr,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: DexColors.successGlow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomBarChart() {
    final heights = [0.3, 0.5, 0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 1.0, 0.7, 0.85, 0.95, 0.65, 0.75, 0.45];
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: heights.map((h) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 180 * h,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    DexColors.primary.withOpacity(0.1),
                    DexColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Vault Section ───
  Widget _buildVaultSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      color: const Color(0xFF030307),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          children: [
            if (!isDesktop) const SizedBox(height: 64),
            Expanded(
              flex: isDesktop ? 6 : 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: DexColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: DexColors.success.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gpp_good, color: DexColors.success, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'INSTITUTIONAL CUSTODY ACTIVE',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: DexColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'IMMUTABLE\n',
                          style: GoogleFonts.outfit(
                            fontSize: isDesktop ? 64 : 40,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'SECURITY.',
                          style: GoogleFonts.outfit(
                            fontSize: isDesktop ? 64 : 40,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: DexColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'We safeguard your principal with central-bank grade parameters: Air-gapped cold multi-sig setups, MPC key segmentation, and Lloyds-backed platform coverage.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSecurityCheck('98% Offline Storage'),
                      _buildSecurityCheck('MPC Multi-Sig keys'),
                      _buildSecurityCheck('Full Capital Coverage'),
                      _buildSecurityCheck('24/7 Node Defense'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCheck(String title) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: DexColors.success, size: 20),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer Section ───
  Widget _buildFooter(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DexColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'DEXTRADE',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '© 2026 Dextrade Protocol. All Rights Reserved.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grid Matrix Custom Painter ───
class GridPainterWidget extends StatelessWidget {
  const GridPainterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1.0;

    const step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Animated Cortex Pulse Nodes Custom Painter ───
class AnimatedNodesWidget extends StatefulWidget {
  const AnimatedNodesWidget({super.key});

  @override
  State<AnimatedNodesWidget> createState() => _AnimatedNodesWidgetState();
}

class _AnimatedNodesWidgetState extends State<AnimatedNodesWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_NodePoint> _nodes = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Generate static node points inside canvas
    for (int i = 0; i < 20; i++) {
      _nodes.add(
        _NodePoint(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          r: 3 + _random.nextDouble() * 5,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _NodesPainter(
            nodes: _nodes,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class _NodePoint {
  final double x;
  final double y;
  final double r;

  _NodePoint({required this.x, required this.y, required this.r});
}

class _NodesPainter extends CustomPainter {
  final List<_NodePoint> nodes;
  final double animationValue;

  _NodesPainter({required this.nodes, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = DexColors.primary.withOpacity(0.1)
      ..strokeWidth = 1.0;

    final paintNode = Paint()..style = PaintingStyle.fill;

    // Draw connecting lines if nodes are close
    for (int i = 0; i < nodes.length; i++) {
      final p1 = Offset(nodes[i].x * size.width, nodes[i].y * size.height);
      for (int j = i + 1; j < nodes.length; j++) {
        final p2 = Offset(nodes[j].x * size.width, nodes[j].y * size.height);
        final dist = (p1 - p2).distance;
        if (dist < 120) {
          paintLine.color = DexColors.primary.withOpacity((1.0 - (dist / 120.0)) * 0.15);
          canvas.drawLine(p1, p2, paintLine);
        }
      }
    }

    // Draw pulsing node points
    for (final node in nodes) {
      final center = Offset(node.x * size.width, node.y * size.height);
      final pulse = math.sin((animationValue * 2 * math.pi) + (node.x * 10)) * 0.5 + 0.5;

      // Pulse Glow Aura
      paintNode.color = DexColors.primary.withOpacity(0.15 * (1.0 - pulse));
      canvas.drawCircle(center, node.r + (pulse * 15), paintNode);

      // Core Node
      paintNode.color = DexColors.accent;
      canvas.drawCircle(center, node.r, paintNode);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
