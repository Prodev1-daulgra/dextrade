import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted) {
      setState(() => _loading = false);
      if (err != null) setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Left Pane: Form (Responsive sizing)
          Expanded(
            flex: isDesktop ? 11 : 20,
            child: Stack(
              children: [
                // Animated background glow (Enhanced for pure black backdrop)
                AnimatedBuilder(
                  animation: _bgController,
                  builder: (_, __) => Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(_bgController.value * 0.4 - 0.2, -0.3),
                        radius: 1.4,
                        colors: [
                          DexColors.primary.withOpacity(0.16),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
                // Form layout
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand Watermark (Left-aligned, outside card for breathing room)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, bottom: 28),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(colors: DexColors.primaryGradient),
                                  ),
                                  child: const Center(
                                    child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('DEXTRADE', style: DexTypography.h2.copyWith(letterSpacing: 2, fontSize: 18)),
                              ],
                            ),
                          ),
                          
                          // Custom blended Dribbble-style glass card
                          GlassCard(
                            padding: const EdgeInsets.all(32),
                            borderRadius: 28,
                            borderColor: Colors.white.withOpacity(0.08),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Form title
                                Text('Welcome Back', style: DexTypography.h1.copyWith(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text('Unlock your high-performance trading terminal.', style: DexTypography.bodySmall.copyWith(color: DexColors.textSecondary)),
                                const SizedBox(height: 32),
 
                                // Email Input
                                Text('USERNAME OR EMAIL', style: DexTypography.label.copyWith(fontSize: 9, letterSpacing: 1, color: DexColors.primaryGlow)),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your email address',
                                    prefixIcon: Icon(Icons.email_outlined, size: 20, color: DexColors.textMuted),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Password Input
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('PASSWORD', style: DexTypography.label.copyWith(fontSize: 9, letterSpacing: 1, color: DexColors.primaryGlow)),
                                    GestureDetector(
                                      onTap: () => DexToast.show(context, 'Password recovery link sent via your configured authentication pipeline.', type: ToastType.info),
                                      child: Text('Forgot Password?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DexColors.accent)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Enter password',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: DexColors.textMuted),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: DexColors.textMuted),
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                  onSubmitted: (_) => _login(),
                                ),

                                if (_error != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: DexColors.error.withOpacity(0.1),
                                      border: Border.all(color: DexColors.error.withOpacity(0.3)),
                                    ),
                                    child: Text(_error!, style: DexTypography.caption.copyWith(color: DexColors.error)),
                                  ),
                                ],

                                const SizedBox(height: 32),
                                GlowButton(
                                  label: 'Sign In',
                                  onPressed: _loading ? null : _login,
                                  isLoading: _loading,
                                  width: double.infinity,
                                ),
                                const SizedBox(height: 28),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("New to Dextrade? ", style: DexTypography.bodySmall),
                                    GestureDetector(
                                      onTap: () => context.go('/register'),
                                      child: Text(
                                        'Sign Up Here!',
                                        style: DexTypography.bodySmall.copyWith(
                                          color: DexColors.accent,
                                          fontWeight: FontWeight.bold,
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
                  color: const Color(0xFF07070E),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      // Grid Overlay for technical texture
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.04,
                          child: GridPaper(
                            color: Colors.white,
                            interval: 50,
                            subdivisions: 1,
                          ),
                        ),
                      ),
                      // Animated orbital glow background
                      const Center(
                        child: Stunning3DGraphic(),
                      ),
                      // Overlay premium copy block
                      Positioned(
                        bottom: 48,
                        left: 48,
                        right: 48,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: DexColors.primary.withOpacity(0.15),
                                border: Border.all(color: DexColors.primary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: DexColors.primary),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('DEXTRADE NEBULA NODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: DexColors.primary)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Institutional Liquidity.\nUnrivaled Execution.', style: DexTypography.h1.copyWith(fontSize: 28, height: 1.2)),
                            const SizedBox(height: 8),
                            Text('Embark on a journey of algorithmic productivity. Mirror elite copy-trading nodes directly to your secure portfolio in real-time.', style: DexTypography.bodySmall.copyWith(color: DexColors.textSecondary)),
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
    );
  }
}

// Stunning Animated 3D-effect Fluid Torus / Sphere Graphic
class Stunning3DGraphic extends StatefulWidget {
  const Stunning3DGraphic({super.key});

  @override
  State<Stunning3DGraphic> createState() => _Stunning3DGraphicState();
}

class _Stunning3DGraphicState extends State<Stunning3DGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(400, 400),
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
    final radius = size.width * 0.32;

    // 1. Deep backdrop aura glow
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          DexColors.primary.withOpacity(0.35),
          DexColors.accent.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2.2));
    canvas.drawCircle(center, radius * 2.2, auraPaint);

    // 2. Render complex overlapping rotating iridescent fluid rings (3D Chrome feel)
    for (int i = 0; i < 4; i++) {
      final angle = (progress * 2 * pi) + (i * pi / 2);
      final offsetMultiplier = 14.0 * (4 - i);
      final offset = Offset(cos(angle) * offsetMultiplier, sin(angle) * offsetMultiplier);
      
      final shapePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DexColors.primary.withOpacity(0.65 - (i * 0.12)),
            DexColors.accent.withOpacity(0.35 - (i * 0.08)),
            Colors.white.withOpacity(0.02),
          ],
        ).createShader(Rect.fromCircle(center: center + offset, radius: radius - (i * 18)))
        ..style = PaintingStyle.fill;

      // Draw shadow layer behind each fluid element
      canvas.drawCircle(
        center + offset + const Offset(10, 20), 
        radius - (i * 18), 
        Paint()..color = Colors.black.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      );

      canvas.drawCircle(center + offset, radius - (i * 18), shapePaint);

      // Glass highlights (White thin rim reflections)
      final borderPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.transparent,
            DexColors.accent.withOpacity(0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center + offset, radius: radius - (i * 18)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center + offset, radius - (i * 18), borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _3DGraphicPainter oldDelegate) => true;
}
