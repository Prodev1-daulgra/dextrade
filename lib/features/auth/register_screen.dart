import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/glass_card.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await ref.read(authProvider.notifier).register(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      fullName: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
    );
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
      backgroundColor: DexColors.background,
      body: Row(
        children: [
          // Left Pane: Form (Responsive sizing)
          Expanded(
            flex: isDesktop ? 11 : 20,
            child: Stack(
              children: [
                // Animated background glow
                AnimatedBuilder(
                  animation: _bgController,
                  builder: (_, __) => Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(_bgController.value * 0.4 - 0.2, -0.3),
                        radius: 1.4,
                        colors: [
                          DexColors.primary.withValues(alpha: 0.08),
                          DexColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
                // Form layout
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand Watermark (Left-aligned)
                          Row(
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
                          const SizedBox(height: 54),
                          
                          // Form title
                          Text('Create Account', style: DexTypography.h1.copyWith(fontSize: 32, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text('Initialize your institutional network terminal node.', style: DexTypography.bodySmall),
                          const SizedBox(height: 36),

                          // Name Input (Optional)
                          Text('FULL NAME (OPTIONAL)', style: DexTypography.label.copyWith(fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameCtrl,
                            style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: DexColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email Input
                          Text('EMAIL ADDRESS', style: DexTypography.label.copyWith(fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Enter your email address',
                              prefixIcon: Icon(Icons.email_outlined, size: 20, color: DexColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password Input
                          Text('PASSWORD', style: DexTypography.label.copyWith(fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Enter a strong password (6+ chars)',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: DexColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: DexColors.textMuted),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            onSubmitted: (_) => _register(),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: DexColors.error.withValues(alpha: 0.1),
                                border: Border.all(color: DexColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Text(_error!, style: DexTypography.caption.copyWith(color: DexColors.error)),
                            ),
                          ],

                          const SizedBox(height: 32),
                          GlowButton(
                            label: 'Create Terminal',
                            onPressed: _loading ? null : _register,
                            isLoading: _loading,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have a terminal? ", style: DexTypography.bodySmall),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  'Sign In',
                                  style: DexTypography.bodySmall.copyWith(
                                    color: DexColors.primary,
                                    fontWeight: FontWeight.bold,
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                                color: DexColors.primary.withValues(alpha: 0.15),
                                border: Border.all(color: DexColors.primary.withValues(alpha: 0.3)),
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
                            Text('Secure Ledger Control.\nInstitutional Custody.', style: DexTypography.h1.copyWith(fontSize: 28, height: 1.2)),
                            const SizedBox(height: 8),
                            Text('Gain absolute control over your digital assets. Secure, multi-signature audited infrastructure backed by high-yield institutional copy portfolios.', style: DexTypography.bodySmall.copyWith(color: DexColors.textSecondary)),
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
          DexColors.primary.withValues(alpha: 0.35),
          DexColors.accent.withValues(alpha: 0.1),
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
            DexColors.primary.withValues(alpha: 0.65 - (i * 0.12)),
            DexColors.accent.withValues(alpha: 0.35 - (i * 0.08)),
            Colors.white.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromCircle(center: center + offset, radius: radius - (i * 18)))
        ..style = PaintingStyle.fill;

      // Draw shadow layer behind each fluid element
      canvas.drawCircle(
        center + offset + const Offset(10, 20), 
        radius - (i * 18), 
        Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      );

      canvas.drawCircle(center + offset, radius - (i * 18), shapePaint);

      // Glass highlights (White thin rim reflections)
      final borderPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.transparent,
            DexColors.accent.withValues(alpha: 0.3),
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
