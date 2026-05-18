import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late final AnimationController _bgController;
  late final AnimationController _starController;
  Offset _mousePosition = Offset.zero;

  // Track field focus to trigger premium neon border glow
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  bool _emailHasFocus = false;
  bool _passHasFocus = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _emailFocus.addListener(() {
      setState(() => _emailHasFocus = _emailFocus.hasFocus);
    });
    _passFocus.addListener(() {
      setState(() => _passHasFocus = _passFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bgController.dispose();
    _starController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted) {
      setState(() => _loading = false);
      if (err != null) {
        setState(() => _error = err);
        DexToast.showPushNotification(context, title: 'Error', body: err);
      } else {
        DexToast.showPushNotification(
          context,
          title: 'Success',
          body: 'Authentication Successful. Syncing Node...',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePosition = event.localPosition;
          });
        },
        child: Row(
          children: [
            // Left Pane: Premium Cyberpunk Glass Form
            Expanded(
              flex: isDesktop ? 11 : 20,
              child: Stack(
                children: [
                  // 1. Drifting Star Particles Background + Ambient Glow Blobs
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _bgController,
                        _starController,
                      ]),
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _AuthBackgroundPainter(
                            bgValue: _bgController.value,
                            starValue: _starController.value,
                            mousePos: _mousePosition,
                            primaryColor: DexColors.primary,
                            accentColor: DexColors.accent,
                          ),
                        );
                      },
                    ),
                  ),

                  // 2. Interactive Form Content
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Premium Brand Watermark (Space Grotesk & Orbitron combination)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                bottom: 32,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: DexColors.primaryGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: DexColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'D',
                                        style: GoogleFonts.orbitron(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DEXTRADE',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'ALPHA CORTEX SYSTEM',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 8,
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

                            // Immersive Glassmorphic Form Card
                            GlassCard(
                              padding: const EdgeInsets.all(36),
                              borderRadius: 32,
                              borderColor: Colors.white.withOpacity(0.06),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Form Title
                                  Text(
                                    'Welcome Back',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Unlock your high-performance matching node.',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: DexColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 36),

                                  // Username / Email input with high-end neon border glow
                                  Text(
                                    'USERNAME OR EMAIL ADDRESS',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      color: _emailHasFocus
                                          ? DexColors.accent
                                          : DexColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.02),
                                      border: Border.all(
                                        color: _emailHasFocus
                                            ? DexColors.accent
                                            : Colors.white.withOpacity(0.08),
                                        width: 1.5,
                                      ),
                                      boxShadow: _emailHasFocus
                                          ? [
                                              BoxShadow(
                                                color: DexColors.accent
                                                    .withOpacity(0.1),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: TextField(
                                      controller: _emailCtrl,
                                      focusNode: _emailFocus,
                                      keyboardType: TextInputType.emailAddress,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: DexColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        fillColor: Colors.transparent,
                                        hintText: 'Enter account email',
                                        prefixIcon: Icon(
                                          Icons.alternate_email_rounded,
                                          size: 20,
                                          color: _emailHasFocus
                                              ? DexColors.accent
                                              : DexColors.textMuted,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Password input
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ACCESS KEYPASS',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          color: _passHasFocus
                                              ? DexColors.primaryGlow
                                              : DexColors.textMuted,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          DexToast.showPushNotification(
                                            context,
                                            title: 'Recovery Initiated',
                                            body:
                                                'Node key recovery system triggered. Check configured notification pathways.',
                                          );
                                        },
                                        child: Text(
                                          'Recover Path?',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: DexColors.accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.02),
                                      border: Border.all(
                                        color: _passHasFocus
                                            ? DexColors.primary
                                            : Colors.white.withOpacity(0.08),
                                        width: 1.5,
                                      ),
                                      boxShadow: _passHasFocus
                                          ? [
                                              BoxShadow(
                                                color: DexColors.primary
                                                    .withOpacity(0.12),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: TextField(
                                      controller: _passCtrl,
                                      focusNode: _passFocus,
                                      obscureText: _obscure,
                                      style: GoogleFonts.jetBrainsMono(
                                        color: DexColors.textPrimary,
                                        fontSize: 15,
                                        letterSpacing: _obscure ? 4.0 : 0.0,
                                      ),
                                      decoration: InputDecoration(
                                        fillColor: Colors.transparent,
                                        hintText: '••••••••',
                                        hintStyle: GoogleFonts.jetBrainsMono(
                                          letterSpacing: 4.0,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          size: 20,
                                          color: _passHasFocus
                                              ? DexColors.primary
                                              : DexColors.textMuted,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscure
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            size: 20,
                                            color: DexColors.textMuted,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscure = !_obscure,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      onSubmitted: (_) => _login(),
                                    ),
                                  ),

                                  if (_error != null) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: DexColors.error.withOpacity(
                                          0.08,
                                        ),
                                        border: Border.all(
                                          color: DexColors.error.withOpacity(
                                            0.2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            color: DexColors.error,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _error!,
                                              style: GoogleFonts.spaceGrotesk(
                                                color: DexColors.errorGlow,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 36),
                                  GlowButton(
                                    label: 'Initialize Sync',
                                    onPressed: _loading ? null : _login,
                                    isLoading: _loading,
                                    width: double.infinity,
                                  ),
                                  const SizedBox(height: 32),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "New to Dextrade? ",
                                        style: GoogleFonts.spaceGrotesk(
                                          color: DexColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => context.go('/register'),
                                        child: Text(
                                          'Claim Node Access',
                                          style: GoogleFonts.spaceGrotesk(
                                            color: DexColors.accent,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Pane: Stunning 3D Graphic (Only shown on Desktop/Web viewports)
            if (isDesktop)
              Expanded(
                flex: 9,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: const Color(0xFF040409),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        // WebGL grid texture overlay
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.03,
                            child: GridPaper(
                              color: Colors.white,
                              interval: 40,
                              subdivisions: 1,
                            ),
                          ),
                        ),

                        // Stunning rotating 3D custom nodes
                        const Center(child: Stunning3DGraphic()),

                        // Premium bottom copy panel
                        Positioned(
                          bottom: 56,
                          left: 56,
                          right: 56,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: DexColors.primary.withOpacity(0.12),
                                  border: Border.all(
                                    color: DexColors.primary.withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: DexColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ALPHA MATCHING ENGINE ACTIVE',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        color: DexColors.primaryGlow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Institutional Liquidity.\nMicrosecond Synchronization.',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Dextrade bypasses traditional slippage loops entirely. Securely link into high-yield algorithmic master nodes directly inside our sovereign hardware custody vault.',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Painter for Drifting Star Particles + Background Globs ───
class _AuthBackgroundPainter extends CustomPainter {
  final double bgValue;
  final double starValue;
  final Offset mousePos;
  final Color primaryColor;
  final Color accentColor;

  _AuthBackgroundPainter({
    required this.bgValue,
    required this.starValue,
    required this.mousePos,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ambient Glowing Blobs (Slowly pulsing)
    final center1 = Offset(
      size.width * 0.1 + math.cos(bgValue * 2 * math.pi) * 60,
      size.height * 0.2 + math.sin(bgValue * 2 * math.pi) * 60,
    );

    final globPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.14),
          primaryColor.withOpacity(0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center1, radius: 320));
    canvas.drawCircle(center1, 320, globPaint1);

    final center2 = Offset(
      size.width * 0.8 + math.sin(bgValue * 2 * math.pi) * 80,
      size.height * 0.8 + math.cos(bgValue * 2 * math.pi) * 80,
    );

    final globPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(0.08),
          accentColor.withOpacity(0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center2, radius: 400));
    canvas.drawCircle(center2, 400, globPaint2);

    // 2. Premium Drifting Stars Particles (Interactive with Mouse Position)
    final starPaint = Paint()..style = PaintingStyle.fill;
    final int starCount = 35;
    final math.Random random = math.Random(142); // Seeded to maintain positions

    for (int i = 0; i < starCount; i++) {
      // Base placement
      final double baseRawX = random.nextDouble() * size.width;
      final double baseRawY = random.nextDouble() * size.height;

      // Slow drift animation
      final double driftAngle = (starValue * 2 * math.pi) + (i * 12.0);
      final double animX = math.cos(driftAngle) * 35.0;
      final double animY = math.sin(driftAngle) * 35.0;

      double finalX = baseRawX + animX;
      double finalY = baseRawY + animY;

      // Wrap around bounds
      finalX = finalX % size.width;
      finalY = finalY % size.height;

      // Subtle mouse attraction force
      final double distToMouse = (Offset(finalX, finalY) - mousePos).distance;
      if (distToMouse < 280 && mousePos != Offset.zero) {
        final double attractionStrength = (1.0 - (distToMouse / 280.0)) * 25.0;
        final Offset diff = mousePos - Offset(finalX, finalY);
        final Offset direction = diff.distance == 0
            ? Offset.zero
            : diff / diff.distance;
        finalX += direction.dx * attractionStrength;
        finalY += direction.dy * attractionStrength;
      }

      // Sparkle pulse
      final double sparkle =
          math.sin((starValue * 2 * math.pi * 3) + i) * 0.5 + 0.5;
      final double radius =
          (1.2 + random.nextDouble() * 2.0) * (0.8 + sparkle * 0.4);

      // Gradient color between primary/accent based on index
      final Color color = Color.lerp(
        primaryColor,
        accentColor,
        random.nextDouble(),
      )!.withOpacity(0.3 + sparkle * 0.5);

      starPaint.color = color;
      canvas.drawCircle(Offset(finalX, finalY), radius, starPaint);

      // Star Glow
      if (random.nextDouble() > 0.7) {
        starPaint.color = color.withOpacity(0.12);
        canvas.drawCircle(Offset(finalX, finalY), radius * 4.0, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AuthBackgroundPainter oldDelegate) => true;
}

// ─── Stunning Rotating 3D Chromatic Sphere Painter ───
class Stunning3DGraphic extends StatefulWidget {
  const Stunning3DGraphic({super.key});

  @override
  State<Stunning3DGraphic> createState() => _Stunning3DGraphicState();
}

class _Stunning3DGraphicState extends State<Stunning3DGraphic>
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
          size: const Size(450, 450),
          painter: _3DGraphicPainter(_controller.value),
        );
      },
    );
  }
}

class _3DGraphicPainter extends CustomPainter {
  final double progress;

  _3DGraphicPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.30;

    // 1. Core background neon aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          DexColors.primary.withOpacity(0.35),
          DexColors.accent.withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 2.0));
    canvas.drawCircle(center, baseRadius * 2.0, auraPaint);

    // 2. Drifting structural nodes & constellation matrix lines around sphere
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..color = DexColors.primary.withOpacity(0.08);

    final int nodeCount = 14;
    final List<Offset> nodeOffsets = [];

    for (int i = 0; i < nodeCount; i++) {
      // Calculate coordinates around 3D sphere shell using sine/cosine projection
      final double phi =
          (i * math.pi / (nodeCount / 2)) + (progress * 2 * math.pi * 0.5);
      final double theta = (i * math.pi / 5.0) + (progress * 2 * math.pi * 0.2);

      // Coordinate projections
      final double x = baseRadius * 1.25 * math.sin(theta) * math.cos(phi);
      final double y = baseRadius * 1.25 * math.cos(theta);
      final double z = baseRadius * 1.25 * math.sin(theta) * math.sin(phi);

      // Only draw and map if coordinate is facing forward (z >= 0) to simulate true 3D projection
      final Offset projectedOffset = center + Offset(x, y);
      nodeOffsets.add(projectedOffset);

      // Scale node based on 3D depth z-axis
      final double depthScale = (z + baseRadius * 1.25) / (baseRadius * 2.5);
      final double sizeMultiplier = 3.0 + depthScale * 5.0;

      nodePaint.color = Color.lerp(
        DexColors.primary,
        DexColors.accent,
        depthScale,
      )!.withOpacity(0.1 + depthScale * 0.8);

      // Draw subtle connectors between sequential nodes
      if (i > 0) {
        linePaint.color = DexColors.primary.withOpacity(
          0.05 + depthScale * 0.1,
        );
        canvas.drawLine(nodeOffsets[i - 1], projectedOffset, linePaint);
      }

      canvas.drawCircle(projectedOffset, sizeMultiplier, nodePaint);

      // Subtle pulse rings around node vectors
      if (i % 3 == 0) {
        final double pulse =
            math.sin((progress * 2 * math.pi * 2) + i) * 0.5 + 0.5;
        canvas.drawCircle(
          projectedOffset,
          sizeMultiplier + pulse * 12.0,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = DexColors.accent.withOpacity(
              (1.0 - pulse) * 0.3 * depthScale,
            ),
        );
      }
    }

    // 3. Render 3D overlapping chrome shells
    for (int i = 0; i < 4; i++) {
      final double angle = (progress * 2 * math.pi) + (i * math.pi / 2);
      final double offsetDist = 12.0 * (4 - i);
      final Offset ringOffset = Offset(
        math.cos(angle) * offsetDist,
        math.sin(angle) * offsetDist,
      );

      final double currentRadius = baseRadius - (i * 16.0);

      // Chromatic Swept Gradient
      final ringPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader =
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DexColors.primary.withOpacity(0.68 - (i * 0.12)),
                DexColors.accent.withOpacity(0.32 - (i * 0.08)),
                Colors.white.withOpacity(0.01),
              ],
            ).createShader(
              Rect.fromCircle(
                center: center + ringOffset,
                radius: currentRadius,
              ),
            );

      // Layered drop shadows
      canvas.drawCircle(
        center + ringOffset + const Offset(12, 18),
        currentRadius,
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );

      canvas.drawCircle(center + ringOffset, currentRadius, ringPaint);

      // High-end Chrome highlights
      final highlightPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader =
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.55),
                Colors.transparent,
                DexColors.accent.withOpacity(0.3),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: center + ringOffset,
                radius: currentRadius,
              ),
            );

      canvas.drawCircle(center + ringOffset, currentRadius, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _3DGraphicPainter oldDelegate) => true;
}
