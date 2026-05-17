import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../widgets/smooth_scroll_wrapper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';

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
    {'sym': 'AVAX/USDT', 'price': '38.45', 'chg': '+4.1%', 'pos': true},
    {'sym': 'LINK/USDT', 'price': '18.92', 'chg': '-1.5%', 'pos': false},
    {'sym': 'NEAR/USDT', 'price': '7.24', 'chg': '+6.8%', 'pos': true},
    {'sym': 'RENDER/USDT', 'price': '9.82', 'chg': '+8.3%', 'pos': true},
    {'sym': 'SUI/USDT', 'price': '3.14', 'chg': '-2.1%', 'pos': false},
  ];

  late final ScrollController _tapeController;
  Timer? _tapeTimer;

  // Interactive hover tracking for parallax background
  Offset _hoverPosition = Offset.zero;

  // 3D Parallax Tilt state for the command deck console
  double _consoleTiltX = 0.0;
  double _consoleTiltY = 0.0;
  bool _isConsoleHovered = false;

  // Active Selected Telemetry Cluster for the Cluster Control Sandbox
  int _activeClusterIndex = 0;

  // Simulated live fluctuating matching clock values
  double _simulatedLatency = 14.24;
  late final Timer _latencyTimer;
  List<String> _simulatedHashes = [];
  late final Timer _hashTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tapeController = ScrollController();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    // Initial mock hashes
    final r = math.Random();
    _simulatedHashes = List.generate(4, (idx) {
      final prefix = ['SHA', 'MD5', 'KECCAK', 'MPC'][r.nextInt(4)];
      final hex = List.generate(8, (i) => '0123456789ABCDEF'[r.nextInt(16)]).join();
      return '[$prefix: $hex]';
    });

    // Fluctuating matching clock
    _latencyTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _simulatedLatency = 14.1 + math.Random().nextDouble() * 0.3;
        });
      }
    });

    // Flashing verification log hashes
    _hashTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _simulatedHashes = List.generate(4, (idx) {
            final prefix = ['SHA', 'MD5', 'KECCAK', 'MPC'][r.nextInt(4)];
            final hex = List.generate(8, (i) => '0123456789ABCDEF'[r.nextInt(16)]).join();
            return '[$prefix: $hex]';
          });
        });
      }
    });

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
    _latencyTimer.cancel();
    _hashTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 900;

    return Scaffold(
      backgroundColor: Colors.black, // Deep pitch obsidian black
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _hoverPosition = event.localPosition;
          });
        },
        child: Stack(
          children: [
            // ─── 1. Parallax Ambient Glowing Orbs ───
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final val = _glowController.value;
                // Parallax shifts orbs slightly based on scroll offset and mouse hover
                final scrollShiftY = _scrollOffset * 0.4;
                final mouseShiftX = (_hoverPosition.dx - screenSize.width / 2) * 0.03;
                final mouseShiftY = (_hoverPosition.dy - screenSize.height / 2) * 0.03;

                return Stack(
                  children: [
                    // Top-Left Primary Orb
                    Positioned(
                      top: -150 + (val * 80) - scrollShiftY + mouseShiftY,
                      left: -200 + (val * 100) + mouseShiftX,
                      child: Container(
                        width: 600,
                        height: 600,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              DexColors.primary.withOpacity(0.12 + (val * 0.06)),
                              DexColors.primary.withOpacity(0.01),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Center-Right Accent Orb
                    Positioned(
                      top: screenSize.height * 0.45 - (scrollShiftY * 0.6) + mouseShiftY * 0.5,
                      right: -250 + (val * 120) - mouseShiftX,
                      child: Container(
                        width: 700,
                        height: 700,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              DexColors.accent.withOpacity(0.08 + (val * 0.04)),
                              DexColors.accent.withOpacity(0.01),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom-Left Success Orb (Node Vault)
                    Positioned(
                      bottom: -200 + scrollShiftY * 0.3 + mouseShiftY * 0.4,
                      left: -150 - mouseShiftX * 0.6,
                      child: Container(
                        width: 550,
                        height: 550,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              DexColors.success.withOpacity(0.06 + (val * 0.04)),
                              DexColors.success.withOpacity(0.00),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // ─── 2. Smooth Scroll Wrapper & Main Scroll Column ───
            SmoothScrollWrapper(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(), // Use clamping to let smooth scroll work nicely
                child: Column(
                  children: [
                    const SizedBox(height: 120),

                    // Hero section
                    _buildHeroSection(context, isDesktop),

                    // Stats Grid
                    _buildStatsGrid(isDesktop),

                    // Brand-New Context Section: Architecture Flow Map (Horizontal Stepper)
                    _buildArchitectureStepper(isDesktop),

                    // Alpha Cortex WebGL Canvas Node Graph
                    _buildCortexSection(isDesktop),

                    // Execution Pipeline Net-Flow & Live Tape
                    _buildPipelineSection(isDesktop),

                    // Vault Custody Section
                    _buildVaultSection(isDesktop),

                    // Footer
                    _buildFooter(isDesktop),
                  ],
                ),
              ),
            ),

            // ─── 3. Frosted Floating Glass Navigation Bar ───
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildNavBar(context, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Navigation Bar Widget ───
  Widget _buildNavBar(BuildContext context, bool isDesktop) {
    final navOpacity = math.min(1.0, _scrollOffset / 120.0);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18.0 * navOpacity,
          sigmaY: 18.0 * navOpacity,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 20,
            vertical: isDesktop ? 20 - (navOpacity * 6) : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35 * navOpacity + 0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.06 * navOpacity),
                width: 1.0,
              ),
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
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
                            gradient: const LinearGradient(
                              colors: DexColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
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
                              style: GoogleFonts.orbitron(
                                fontSize: isDesktop ? 18 : 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                            if (isDesktop)
                              Text(
                                'ALPHA CORTEX SYSTEM',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  color: DexColors.accent,
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
                        _buildNavLink('Cortex Routing'),
                        _buildNavLink('Match Engine'),
                        _buildNavLink('Cold Custody'),
                        _buildNavLink('Mirror Index'),
                      ],
                    ),

                  // Auth Actions
                  Row(
                    children: [
                      if (isDesktop) ...[
                        TextButton(
                          onPressed: () => context.push('/login'),
                          child: Text(
                            'LOG IN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      GlowButton(
                        label: isDesktop ? 'ACQUIRE NODE' : 'ACQUIRE',
                        onPressed: () => context.push('/register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  // ─── Hero Section ───
  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 1400), // Wider for editorial
            child: isDesktop ? _buildDesktopHero() : _buildMobileHero(),
          ),

          const SizedBox(height: 100),

          // Ticker Tape widget
          _buildTickerTape(),
        ],
      ),
    );
  }

  Widget _buildDesktopHero() {
    return SizedBox(
      height: 650,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background abstract accent
          Positioned(
            right: 100,
            top: 50,
            child: Container(
              width: 400,
              height: 500,
              decoration: BoxDecoration(
                border: Border.all(color: DexColors.primary.withValues(alpha: 0.1)),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), bottomRight: Radius.circular(100)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DexColors.primary.withValues(alpha: 0.05), Colors.transparent],
                ),
              ),
            ),
          ).animate().fade(delay: 600.ms).slideX(begin: 0.1),

          // Massive Editorial Typography
          Positioned(
            left: 0,
            top: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INSTITUTIONAL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    height: 0.85,
                    color: Colors.white,
                    letterSpacing: -4,
                  ),
                ).animate().fade(delay: 100.ms).slideY(begin: 0.2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIQUIDITY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 120,
                        fontWeight: FontWeight.w900,
                        height: 0.85,
                        color: DexColors.primary,
                        letterSpacing: -4,
                        shadows: [Shadow(color: DexColors.primary.withValues(alpha: 0.4), blurRadius: 40)],
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(width: 24),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          border: Border(left: BorderSide(color: DexColors.primary, width: 2)),
                        ),
                        child: Text(
                          'Bypassing heuristic algorithms. Direct matching engine access for high-frequency algorithmic routing.',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: DexColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ).animate().fade(delay: 500.ms),
                    ),
                  ],
                ),
                Text(
                  'PROTOCOL.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    height: 0.85,
                    color: Colors.transparent,
                    letterSpacing: -4,
                    shadows: [Shadow(color: Colors.white.withValues(alpha: 0.3), offset: const Offset(0, 0), blurRadius: 2)],
                  ),
                ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
              ],
            ),
          ),

          // Floating Command Deck (Interactive Sandbox)
          Positioned(
            right: 0,
            top: 140,
            width: 480,
            child: _buildPerspectiveConsole(),
          ),

          // CTAs & Stats at bottom left
          Positioned(
            left: 0,
            bottom: 0,
            child: Row(
              children: [
                GlowButton(
                  label: 'INITIALIZE NODE',
                  onPressed: () {},
                  width: 220,
                ),
                const SizedBox(width: 24),
                _buildEditorialStat('LATENCY', '14.2ms'),
                const SizedBox(width: 32),
                _buildEditorialStat('CUSTODY', 'COLD'),
              ],
            ).animate().fade(delay: 700.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSTITUTIONAL\nLIQUIDITY\nPROTOCOL.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            height: 0.9,
            color: Colors.white,
            letterSpacing: -2,
          ),
        ).animate().fade().slideY(begin: 0.1),
        const SizedBox(height: 24),
        Text(
          'Direct matching engine access for high-frequency algorithmic routing.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: DexColors.textSecondary,
            height: 1.6,
          ),
        ).animate().fade(delay: 200.ms),
        const SizedBox(height: 40),
        SizedBox(height: 400, child: _buildPerspectiveConsole()),
        const SizedBox(height: 40),
        GlowButton(
          label: 'INITIALIZE NODE',
          onPressed: () {},
          width: double.infinity,
        ).animate().fade(delay: 400.ms),
      ],
    );
  }

  Widget _buildEditorialStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w800, color: DexColors.primary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
      ],
    );
  }

  Widget _buildPerspectiveConsole() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isConsoleHovered = true),
      onExit: (_) => setState(() {
        _isConsoleHovered = false;
        _consoleTiltX = 0.0;
        _consoleTiltY = 0.0;
      }),
      onHover: (event) {
        setState(() {
          _consoleTiltX = (event.localPosition.dy - 200) / 200;
          _consoleTiltY = (event.localPosition.dx - 240) / 240;
        });
      },
      child: AnimatedRotation(
        turns: 0,
        duration: const Duration(milliseconds: 100),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_isConsoleHovered ? -_consoleTiltX * 0.15 : 0.0)
            ..rotateY(_isConsoleHovered ? _consoleTiltY * 0.15 : 0.0),
          alignment: Alignment.center,
          child: Container(
            height: 420,
            decoration: BoxDecoration(
              color: const Color(0xFF020205),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isConsoleHovered 
                    ? DexColors.primary.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: DexColors.primary.withValues(alpha: 0.1),
                  blurRadius: 50,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  const Positioned.fill(child: GridPainterWidget()),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ALPHA CORTEX', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54)),
                              const PulseDot(color: DexColors.success, size: 8),
                            ],
                          ),
                          const Spacer(),
                          Text('LATENCY', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: DexColors.textMuted)),
                          Text('${_simulatedLatency.toStringAsFixed(2)}ms', style: GoogleFonts.spaceGrotesk(fontSize: 48, fontWeight: FontWeight.w900, color: DexColors.primaryGlow, height: 1.0)),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white.withValues(alpha: 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _simulatedHashes.map((h) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(h, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white38)),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fade(delay: 500.ms).slideX(begin: 0.1);
  }

  // Infinite Horizontal Ticker Tape
  Widget _buildTickerTape() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.005),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
      ),
      child: SizedBox(
        height: 30,
        child: ListView.builder(
          controller: _tapeController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final trade = _mockTrades[index % _mockTrades.length];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  Text(
                    trade['sym'],
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '\$${trade['price']}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: trade['pos']
                          ? DexColors.success.withOpacity(0.08)
                          : DexColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: trade['pos']
                            ? DexColors.success.withOpacity(0.15)
                            : DexColors.error.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      trade['chg'],
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8,
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

  // ─── Honeycomb Telemetry Grid ───
  Widget _buildStatsGrid(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'ENGINEERING PARAMETERS',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: DexColors.primaryGlow,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Designed for Sovereign Performance',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: isDesktop ? 42 : 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 56),

            // High-End Asymmetric Layout Deck
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Massive Primary Widescreen Core Monitor (55% width)
                  Expanded(
                    flex: 6,
                    child: _buildTelemetryCoreCard(),
                  ),
                  const SizedBox(width: 24),
                  // Stacked Nested Sub-Telemetry Channels (45% width)
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildSubTelemetryCard(
                          icon: Icons.stacked_line_chart_rounded,
                          title: 'Verifiable Ledger Index',
                          desc: 'All trader allocation histories are secured in public cryptographic ledgers.',
                          statLabel: 'PLATFORM VALUE',
                          statValue: '\$1.42B',
                          iconColor: DexColors.accent,
                        ),
                        const SizedBox(height: 24),
                        _buildSubTelemetryCard(
                          icon: Icons.gpp_good_rounded,
                          title: 'MPC Vault Protection',
                          desc: 'Asset custody is strictly managed via air-gapped multi-party computation security grids.',
                          statLabel: 'TRANSACTION SUCCESS',
                          statValue: '99.8%',
                          iconColor: DexColors.success,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildTelemetryCoreCard(),
                  const SizedBox(height: 24),
                  _buildSubTelemetryCard(
                    icon: Icons.stacked_line_chart_rounded,
                    title: 'Verifiable Ledger Index',
                    desc: 'All trader allocation histories are secured in public cryptographic ledgers.',
                    statLabel: 'PLATFORM VALUE',
                    statValue: '\$1.42B',
                    iconColor: DexColors.accent,
                  ),
                  const SizedBox(height: 24),
                  _buildSubTelemetryCard(
                    icon: Icons.gpp_good_rounded,
                    title: 'MPC Vault Protection',
                    desc: 'Asset custody is strictly managed via air-gapped multi-party computation security grids.',
                    statLabel: 'TRANSACTION SUCCESS',
                    statValue: '99.8%',
                    iconColor: DexColors.success,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Widescreen Core Monitor Widget (Bespoke design)
  Widget _buildTelemetryCoreCard() {
    return GlassCard(
      padding: const EdgeInsets.all(36),
      borderRadius: 28,
      borderColor: DexColors.primary.withOpacity(0.12),
      child: Stack(
        children: [
          Positioned.fill(
            child: CardAmbientShaderWidget(themeColor: DexColors.primary),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DexColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: DexColors.primary.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on_rounded, color: DexColors.primary, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          'PRIMARY CORE MONITOR',
                          style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w900, color: DexColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'LATENCY INDEX',
                    style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white24),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Microsecond Execution',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Distributed synchronization pipelines copy master positions instantly, completely neutralizing execution slippage loops.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DexColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Glowing Pulsing Speed Dial Gauge Widget
                  const MatchingSpeedGaugeWidget(),
                ],
              ),
              const SizedBox(height: 36),
              Container(height: 1, color: Colors.white.withOpacity(0.06)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALPHA SYNC DELAY',
                        style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white30),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '14.2ms',
                        style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Text('VERIFY ENGINE', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_outward_rounded, color: Colors.white70, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stacked Nested Sub-Telemetry Channel
  Widget _buildSubTelemetryCard({
    required IconData icon,
    required String title,
    required String desc,
    required String statLabel,
    required String statValue,
    required Color iconColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 22,
      borderColor: Colors.white.withOpacity(0.03),
      child: Stack(
        children: [
          Positioned.fill(
            child: CardAmbientShaderWidget(themeColor: iconColor),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.15)),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 20),
              Expanded(
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
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: DexColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statLabel,
                              style: GoogleFonts.orbitron(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white30),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statValue,
                              style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BRAND-NEW CONTEXT SECTION: INTERACTIVE CORTEX CLUSTER SANDBOX ───
  Widget _buildArchitectureStepper(bool isDesktop) {
    final clusters = [
      {
        'title': 'Atomic WebSocket Sync',
        'desc': 'Directly link execution tunnels with matching node pings, capturing intent at institutional inception.',
        'color': DexColors.primary,
        'icon': Icons.cable_rounded,
        'metric': '1.2ms PING',
      },
      {
        'title': 'Alpha Cortex Routing',
        'desc': 'Advanced predictive evaluation models paths down high-performance execution pools instantly.',
        'color': DexColors.accent,
        'icon': Icons.hub_rounded,
        'metric': '5M TPS',
      },
      {
        'title': 'Sovereign MPC Custody',
        'desc': 'Cryptographic multi-party segregation seals credentials behind high-security air-gapped vaults.',
        'color': DexColors.success,
        'icon': Icons.shield_moon_rounded,
        'metric': 'AIR-GAPPED',
      },
      {
        'title': 'Instant Yield Settlement',
        'desc': 'Matching nodes clear ledgers and dispatch yields in under 15 milliseconds back to vault balances.',
        'color': Colors.cyan,
        'icon': Icons.auto_graph_rounded,
        'metric': '<15ms CLEAR',
      },
    ];

    Widget buildSandboxDisplay() {
      final active = clusters[_activeClusterIndex];
      final color = active['color'] as Color;
      return GlassCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 28,
        borderColor: color.withOpacity(0.15),
        child: Stack(
          children: [
            Positioned.fill(child: CardAmbientShaderWidget(themeColor: color)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(active['icon'] as IconData, color: color, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'CLUSTER STAGE 0${_activeClusterIndex + 1} ACTIVE',
                            style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: color),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      active['metric'] as String,
                      style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  active['title'] as String,
                  style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  active['desc'] as String,
                  style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500, color: DexColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 40),
                
                // Active Interactive Terminal Logs for Sandbox
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020205),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLUSTER DIAGNOSTICS & TELEMETRY', style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white30)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            itemBuilder: (context, idx) {
                              // We use the existing mock hashes just to simulate live terminal activity
                              final hash = _simulatedHashes.length > idx ? _simulatedHashes[idx] : '[SYSOK: READY]';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Text('>', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Validating constraint matrix... $hash',
                                        style: GoogleFonts.jetBrainsMono(fontSize: 11.5, fontWeight: FontWeight.w500, color: Colors.white60),
                                      ),
                                    ),
                                    Text(
                                      '${(_simulatedLatency + idx * 0.1).toStringAsFixed(2)}ms',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white38),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'CORTEX CLUSTER SANDBOX',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: DexColors.primaryGlow,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Interactive Execution Protocol',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: isDesktop ? 42 : 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 56),

            // Asymmetric Interactive Layout
            if (isDesktop)
              SizedBox(
                height: 540,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Side: Vertical Selector List
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: List.generate(clusters.length, (idx) {
                          final isActive = _activeClusterIndex == idx;
                          final color = clusters[idx]['color'] as Color;
                          return Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => setState(() => _activeClusterIndex = idx),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isActive ? color.withOpacity(0.08) : Colors.white.withOpacity(0.01),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive ? color.withOpacity(0.3) : Colors.white.withOpacity(0.03),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isActive ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(clusters[idx]['icon'] as IconData, color: isActive ? color : Colors.white54, size: 20),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          clusters[idx]['title'] as String,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 18,
                                            fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                                            color: isActive ? Colors.white : Colors.white60,
                                          ),
                                        ),
                                      ),
                                      if (isActive)
                                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right Side: Sandbox Preview Window
                    Expanded(
                      flex: 6,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_activeClusterIndex),
                          child: buildSandboxDisplay(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Selectors
                  Column(
                    children: List.generate(clusters.length, (idx) {
                      final isActive = _activeClusterIndex == idx;
                      final color = clusters[idx]['color'] as Color;
                      return GestureDetector(
                        onTap: () => setState(() => _activeClusterIndex = idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isActive ? color.withOpacity(0.08) : Colors.white.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive ? color.withOpacity(0.3) : Colors.white.withOpacity(0.03),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(clusters[idx]['icon'] as IconData, color: isActive ? color : Colors.white54, size: 20),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  clusters[idx]['title'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                                    color: isActive ? Colors.white : Colors.white60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 480,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: KeyedSubtree(
                        key: ValueKey(_activeClusterIndex),
                        child: buildSandboxDisplay(),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ─── Alpha Cortex Section with Drifting Particle Node Graph ───
  Widget _buildCortexSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Features
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
                        const Icon(Icons.memory_rounded, color: DexColors.primary, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'CORTEX ALIGNMENT ENGINES',
                          style: GoogleFonts.orbitron(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
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
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: isDesktop ? 56 : 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'CORTEX DIAGRAM.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: isDesktop ? 56 : 36,
                            fontWeight: FontWeight.w900,
                            color: DexColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Our proprietary alpha cortex matching node continuously maps sentiment and liquidity fields, algorithmically routing copy orders into optimized vaults while enforcing institutional guardrails.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: DexColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildCortexFeature(Icons.bubble_chart_rounded, 'NEURAL SENTIMENT ROUTING', 'Distributed WebSocket alignment of copy portfolios.'),
                  const SizedBox(height: 24),
                  _buildCortexFeature(Icons.donut_large_rounded, 'PROBABILISTIC YIELD CURVE', 'Advanced mathematical modeling mapping yield targets.'),
                  const SizedBox(height: 24),
                  _buildCortexFeature(Icons.security_rounded, 'AUTOMATED LIQUIDITY SAFEGUARD', 'Direct MPC cold storage key integration.'),
                ],
              ),
            ),

            if (isDesktop) const SizedBox(width: 80) else const SizedBox(height: 64),

            // Right: Floating Drifting Particle Node System (WebGL-Style Interactive CustomPaint)
            Expanded(
              flex: isDesktop ? 6 : 0,
              child: Container(
                height: 480,
                decoration: BoxDecoration(
                  color: const Color(0xFF030308),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: GridPainterWidget(),
                      ),
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
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Icon(icon, color: DexColors.primary, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  color: DexColors.textSecondary,
                ),
              ),
            ],
          ),
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
                      'FLOW MONITORING',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: DexColors.primaryGlow,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mirror Pool Index',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isDesktop ? 42 : 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: DexColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DexColors.success.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: DexColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE SIGNAL ENGINE',
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: DexColors.successGlow,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            GlassCard(
              padding: const EdgeInsets.all(32),
              borderRadius: 32,
              borderColor: Colors.white.withOpacity(0.04),
              child: Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                    flex: isDesktop ? 7 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL LIQUIDITY CONSOLIDATED',
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white30,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$142,392,448',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: isDesktop ? 52 : 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Chart representation
                        _buildCustomBarChart(),
                      ],
                    ),
                  ),
                  if (isDesktop) const SizedBox(width: 48) else const SizedBox(height: 48),
                  Expanded(
                    flex: isDesktop ? 5 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIVE INTEGRATION STREAMS',
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: DexColors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTradeRow('SOL/USDT', 'MIRROR_ACQ_902', '\$198.12', '+15.2% APR', true),
                          const Divider(color: Colors.white10, height: 24),
                          _buildTradeRow('ETH/USDT', 'MIRROR_ACQ_104', '\$3,842.50', '+9.8% APR', true),
                          const Divider(color: Colors.white10, height: 24),
                          _buildTradeRow('BTC/USDT', 'MIRROR_ACQ_942', '\$97,240.00', '+12.4% APR', true),
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
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              node,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
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
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              apr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DexColors.successGlow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomBarChart() {
    final heights = [0.3, 0.5, 0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 1.0, 0.7, 0.85, 0.95, 0.65, 0.75, 0.5];
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    DexColors.primary.withOpacity(0.08),
                    DexColors.primary.withOpacity(0.7),
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
      color: const Color(0xFF020206),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                flex: isDesktop ? 6 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: DexColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: DexColors.success.withOpacity(0.18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gpp_good_rounded, color: DexColors.success, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'HARDWARE CUSTODY PROTECTION OPERATIONAL',
                            style: GoogleFonts.orbitron(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
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
                            text: 'SOVEREIGN\n',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: isDesktop ? 56 : 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'PLATFORM VAULT.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: isDesktop ? 56 : 36,
                              fontWeight: FontWeight.w900,
                              color: DexColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Platform capital is preserved under hardware multi-party segmentation configurations. We guarantee Offline custody backing, continuous node defense scans, and sovereign MPC authorization routes.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: DexColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 44),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildSecurityCheck('98.4% Cold Vault Storage'),
                        _buildSecurityCheck('Multi-Sig MPC Segregation'),
                        _buildSecurityCheck('Lloyds Platform Coverage'),
                        _buildSecurityCheck('24/7 Active Node Firewalls'),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isDesktop) const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCheck(String title) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.015),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: DexColors.success, size: 18),
          const SizedBox(width: 14),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: DexColors.primaryGradient),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flash_on, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'DEXTRADE',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '© 2026 Dextrade Protocol. Sovereign Financial Systems.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
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
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1.0;

    const step = 32.0;
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

// ─── High-Fidelity Floating Drifting Particle Node Painter (Interactive WebGL-Style) ───
class AnimatedNodesWidget extends StatefulWidget {
  const AnimatedNodesWidget({super.key});

  @override
  State<AnimatedNodesWidget> createState() => _AnimatedNodesWidgetState();
}

class _AnimatedNodesWidgetState extends State<AnimatedNodesWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_DriftingNode> _nodes = [];
  final math.Random _random = math.Random(1337); // Seeded random for consistency
  Offset _localPointerPos = Offset.zero;
  bool _isHovering = false;
  double _lastWidth = 0;
  double _lastHeight = 0;

  // Active ripples from user clicks
  final List<_ClickRipple> _ripples = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerEvent event) {
    setState(() {
      _localPointerPos = event.localPosition;
      _isHovering = true;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _isHovering = false;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _ripples.add(
        _ClickRipple(
          origin: event.localPosition,
          progress: 0.0,
          maxRadius: 180.0,
        ),
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    setState(() {
      _localPointerPos = event.localPosition;
      _isHovering = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isHovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Initialize or adjust nodes dynamically if size changes
        if (_nodes.isEmpty || _lastWidth != width || _lastHeight != height) {
          _lastWidth = width;
          _lastHeight = height;
          _nodes.clear();
          // High performance: fewer nodes on mobile browsers to keep performance lightning fast
          final particleCount = width < 600 ? 12 : 28;
          for (int i = 0; i < particleCount; i++) {
            _nodes.add(
              _DriftingNode(
                posX: _random.nextDouble() * width,
                posY: _random.nextDouble() * height,
                velX: (_random.nextDouble() - 0.5) * 0.4,
                velY: (_random.nextDouble() - 0.5) * 0.4,
                baseRadius: 3 + _random.nextDouble() * 4,
                glowPhaseOffset: _random.nextDouble() * 2 * math.pi,
              ),
            );
          }
        }

        return MouseRegion(
          onHover: _onPointerHover,
          onExit: _onPointerExit,
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                _updateParticlePositions(width, height);
                _updateRipples();
                return CustomPaint(
                  painter: _HifiNodesPainter(
                    nodes: _nodes,
                    ripples: _ripples,
                    pointerPos: _localPointerPos,
                    isHovering: _isHovering,
                    primaryColor: DexColors.primary,
                    accentColor: DexColors.accent,
                    animationVal: _controller.value,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _updateParticlePositions(double width, double height) {
    // Update drifting math logic per frame trigger
    for (var node in _nodes) {
      node.posX += node.velX;
      node.posY += node.velY;

      // Bounce nodes inside actual responsive bounds
      if (node.posX < 0) {
        node.posX = 0;
        node.velX *= -1;
      } else if (node.posX > width) {
        node.posX = width;
        node.velX *= -1;
      }

      if (node.posY < 0) {
        node.posY = 0;
        node.velY *= -1;
      } else if (node.posY > height) {
        node.posY = height;
        node.velY *= -1;
      }

      // Pointer attraction / repulsion dynamics
      if (_isHovering) {
        final dist = (Offset(node.posX, node.posY) - _localPointerPos).distance;
        if (dist < 150) {
          final force = (1.0 - (dist / 150.0)) * 0.12;
          final diff = _localPointerPos - Offset(node.posX, node.posY);
          final direction = diff.distance == 0 ? Offset.zero : diff / diff.distance;
          node.posX += direction.dx * force;
          node.posY += direction.dy * force;
        }
      }
    }
  }

  void _updateRipples() {
    for (int i = _ripples.length - 1; i >= 0; i--) {
      _ripples[i].progress += 0.024;
      if (_ripples[i].progress >= 1.0) {
        _ripples.removeAt(i);
      }
    }
  }
}

class _DriftingNode {
  double posX;
  double posY;
  double velX;
  double velY;
  final double baseRadius;
  final double glowPhaseOffset;

  _DriftingNode({
    required this.posX,
    required this.posY,
    required this.velX,
    required this.velY,
    required this.baseRadius,
    required this.glowPhaseOffset,
  });
}

class _ClickRipple {
  final Offset origin;
  double progress;
  final double maxRadius;

  _ClickRipple({
    required this.origin,
    required this.progress,
    required this.maxRadius,
  });
}

class _HifiNodesPainter extends CustomPainter {
  final List<_DriftingNode> nodes;
  final List<_ClickRipple> ripples;
  final Offset pointerPos;
  final bool isHovering;
  final Color primaryColor;
  final Color accentColor;
  final double animationVal;

  _HifiNodesPainter({
    required this.nodes,
    required this.ripples,
    required this.pointerPos,
    required this.isHovering,
    required this.primaryColor,
    required this.accentColor,
    required this.animationVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..strokeWidth = 1.0;
    final nodePaint = Paint()..style = PaintingStyle.fill;

    // 1. Draw connecting structural lines with proximity fades
    for (int i = 0; i < nodes.length; i++) {
      final p1 = Offset(nodes[i].posX.clamp(0, size.width), nodes[i].posY.clamp(0, size.height));

      for (int j = i + 1; j < nodes.length; j++) {
        final p2 = Offset(nodes[j].posX.clamp(0, size.width), nodes[j].posY.clamp(0, size.height));
        final dist = (p1 - p2).distance;

        if (dist < 110) {
          final progress = 1.0 - (dist / 110.0);
          final double opacity = 0.08 * progress;

          // Color connectors between primary/accent dynamically based on indexes
          linePaint.color = Color.lerp(primaryColor, accentColor, i / nodes.length)!.withOpacity(opacity);
          canvas.drawLine(p1, p2, linePaint);

          // Draw floating animated data packet pulses down the connection pathways
          final double pulseTime = (animationVal * 3 + (i + j)) % 1.0;
          final Offset packetOffset = Offset.lerp(p1, p2, pulseTime)!;
          nodePaint.color = accentColor.withOpacity(0.3 * progress);
          canvas.drawCircle(packetOffset, 1.5, nodePaint);
        }
      }
    }

    // 2. Draw active user click ripples (Visual ping indicator)
    for (var ripple in ripples) {
      final double currentRadius = ripple.maxRadius * ripple.progress;
      final double opacity = 1.0 - ripple.progress;
      final Paint ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = accentColor.withOpacity(0.35 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(ripple.origin, currentRadius, ripplePaint);
    }

    // 3. Draw premium pulsing glowing nodes
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final center = Offset(node.posX.clamp(0, size.width), node.posY.clamp(0, size.height));

      // Calculate dynamic breathing pulse
      final double pulse = math.sin((animationVal * 2 * math.pi * 1.5) + node.glowPhaseOffset) * 0.5 + 0.5;
      final double radius = node.baseRadius * (0.85 + pulse * 0.3);

      // Node aura glow
      final Paint auraPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = primaryColor.withOpacity(0.12 * (1.0 - pulse))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius + (pulse * 14.0), auraPaint);

      // Core fills
      nodePaint.color = Color.lerp(primaryColor, accentColor, i / nodes.length)!;
      canvas.drawCircle(center, radius, nodePaint);

      // Small chrome center dot reflection
      nodePaint.color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(center + Offset(-radius * 0.25, -radius * 0.25), radius * 0.3, nodePaint);
    }

    // 4. Draw interactive pointer glowing reticle ring
    if (isHovering && pointerPos != Offset.zero) {
      final Paint reticlePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = primaryColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(pointerPos, 20.0, reticlePaint);

      reticlePaint
        ..strokeWidth = 1.5
        ..color = accentColor.withOpacity(0.6)
        ..maskFilter = null;
      canvas.drawCircle(pointerPos, 4.0, reticlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedTechGraphicWidget extends StatefulWidget {
  final String step;
  final Color themeColor;

  const AnimatedTechGraphicWidget({
    super.key,
    required this.step,
    required this.themeColor,
  });

  @override
  State<AnimatedTechGraphicWidget> createState() => _AnimatedTechGraphicWidgetState();
}

class _AnimatedTechGraphicWidgetState extends State<AnimatedTechGraphicWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _TechGraphicPainter(
              step: widget.step,
              color: widget.themeColor,
              animationVal: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _TechGraphicPainter extends CustomPainter {
  final String step;
  final Color color;
  final double animationVal;

  _TechGraphicPainter({
    required this.step,
    required this.color,
    required this.animationVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background capsule border
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    if (step == '01') {
      // Radiating WebSocket Sync ping
      final center = Offset(size.width / 2, size.height / 2);
      final beaconPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      // Draw static background waves
      for (int i = 0; i < 3; i++) {
        final progress = (animationVal + i / 3.0) % 1.0;
        final wavePaint = Paint()
          ..color = color.withOpacity((1.0 - progress) * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, progress * 40, wavePaint);
      }
      canvas.drawCircle(center, 4, beaconPaint);
      canvas.drawCircle(center, 10, Paint()..color = color.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    } else if (step == '02') {
      // Neural branching path routing
      final startY = size.height / 2;
      final startX = 30.0;
      final endX = size.width - 30.0;
      
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final targetsY = [15.0, size.height / 2, size.height - 15.0];
      
      for (final targetY in targetsY) {
        final path = Path()
          ..moveTo(startX, startY)
          ..cubicTo(startX + (endX - startX) / 2, startY, startX + (endX - startX) / 2, targetY, endX, targetY);
        canvas.drawPath(path, linePaint);
        
        // Draw traveling glowing packet
        final progress = animationVal;
        final t = progress;
        // Cubic bezier interpolation formula
        final p0 = Offset(startX, startY);
        final p1 = Offset(startX + (endX - startX) / 2, startY);
        final p2 = Offset(startX + (endX - startX) / 2, targetY);
        final p3 = Offset(endX, targetY);
        
        final x = (1-t)*(1-t)*(1-t)*p0.dx + 3*(1-t)*(1-t)*t*p1.dx + 3*(1-t)*t*t*p2.dx + t*t*t*p3.dx;
        final y = (1-t)*(1-t)*(1-t)*p0.dy + 3*(1-t)*(1-t)*t*p1.dy + 3*(1-t)*t*t*p2.dy + t*t*t*p3.dy;
        
        final packetPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 3, packetPaint);
        canvas.drawCircle(Offset(x, y), 8, Paint()..color = color.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }
    } else if (step == '03') {
      // Overlapping lock keys (Sovereign MPC Custody)
      final center = Offset(size.width / 2, size.height / 2);
      final radius = 20.0;
      
      final ringPaint = Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, radius, ringPaint);
      
      // Orbiting key nodes
      final angleStep = 2 * math.pi / 3;
      for (int i = 0; i < 3; i++) {
        final currentAngle = animationVal * 2 * math.pi + i * angleStep;
        final nodePos = Offset(
          center.dx + radius * math.cos(currentAngle),
          center.dy + radius * math.sin(currentAngle),
        );
        final keyPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(nodePos, 3.5, keyPaint);
        canvas.drawCircle(nodePos, 8, Paint()..color = color.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      }
      
      // Core vault shield node
      final corePaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 8, corePaint);
      canvas.drawCircle(center, 8, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.0);
    } else if (step == '04') {
      // High frequency settlement sparkline (Instant Yield Settlement)
      final points = <Offset>[];
      const count = 15;
      final stepX = (size.width - 20) / (count - 1);
      final timeOffset = animationVal * 2 * math.pi;
      
      for (int i = 0; i < count; i++) {
        final x = 10.0 + i * stepX;
        final waveVal = math.sin(i * 0.8 - timeOffset) * math.cos(i * 0.4 + timeOffset);
        final y = size.height / 2 + waveVal * 16.0;
        points.add(Offset(x, y));
      }
      
      final chartPaint = Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      final glowPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      canvas.drawPath(path, chartPaint);
      
      // Draw glowing sliding bullet node on the wave
      final index = ((animationVal * points.length).floor()) % points.length;
      final bulletPos = points[index];
      
      canvas.drawPath(path, glowPaint);
      canvas.drawCircle(bulletPos, 4.5, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(bulletPos, 9, Paint()..color = color.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _TechGraphicPainter oldDelegate) =>
      oldDelegate.animationVal != animationVal || oldDelegate.color != color || oldDelegate.step != step;
}

class CardAmbientShaderWidget extends StatefulWidget {
  final Color themeColor;
  const CardAmbientShaderWidget({super.key, required this.themeColor});

  @override
  State<CardAmbientShaderWidget> createState() => _CardAmbientShaderWidgetState();
}

class _CardAmbientShaderWidgetState extends State<CardAmbientShaderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
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
      builder: (context, _) {
        return CustomPaint(
          painter: _CardAmbientShaderPainter(
            color: widget.themeColor,
            animationVal: _controller.value,
          ),
        );
      },
    );
  }
}

class _CardAmbientShaderPainter extends CustomPainter {
  final Color color;
  final double animationVal;

  _CardAmbientShaderPainter({required this.color, required this.animationVal});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Subtle cyber grid lines drifting slowly
    final double step = 24.0;
    final double offset = animationVal * step;
    
    for (double x = offset; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = offset; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Glowing subtle neon aura at the top right of the card boundary
    final center = Offset(size.width * 0.85, size.height * 0.25);
    final glowPaint = Paint()
      ..color = color.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28.0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 45, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CardAmbientShaderPainter oldDelegate) =>
      oldDelegate.animationVal != animationVal || oldDelegate.color != color;
}

class MatchingSpeedGaugeWidget extends StatefulWidget {
  const MatchingSpeedGaugeWidget({super.key});

  @override
  State<MatchingSpeedGaugeWidget> createState() => _MatchingSpeedGaugeWidgetState();
}

class _MatchingSpeedGaugeWidgetState extends State<MatchingSpeedGaugeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
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
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _GaugePainter(value: _controller.value),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi, math.pi * 2, false, basePaint);

    final fillPaint = Paint()
      ..shader = const LinearGradient(colors: DexColors.primaryGradient).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);
    
    // Animate arc from 30% to 90% filling
    final sweepAngle = math.pi * 2 * (0.3 + value * 0.6);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.value != value;
}
