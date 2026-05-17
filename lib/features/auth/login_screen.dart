import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/glass_card.dart';

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
    return Scaffold(
      backgroundColor: DexColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(_bgController.value * 0.5 - 0.25, -0.3),
                  radius: 1.2,
                  colors: [
                    DexColors.primary.withValues(alpha: 0.08),
                    DexColors.background,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(colors: DexColors.primaryGradient),
                        boxShadow: [
                          BoxShadow(color: DexColors.primary.withValues(alpha: 0.3), blurRadius: 30),
                        ],
                      ),
                      child: const Center(
                        child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('DEXTRADE', style: DexTypography.h1.copyWith(letterSpacing: 4)),
                    const SizedBox(height: 8),
                    Text('Access your terminal', style: DexTypography.bodySmall),
                    const SizedBox(height: 48),

                    // Form
                    GlassCard(
                      padding: const EdgeInsets.all(28),
                      borderRadius: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('SIGN IN', style: DexTypography.label.copyWith(color: DexColors.primary)),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Email address',
                              prefixIcon: Icon(Icons.email_outlined, size: 20, color: DexColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Password',
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
                                color: DexColors.error.withValues(alpha: 0.1),
                                border: Border.all(color: DexColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Text(_error!, style: DexTypography.caption.copyWith(color: DexColors.error)),
                            ),
                          ],
                          const SizedBox(height: 28),
                          GlowButton(
                            label: 'Initialize Session',
                            onPressed: _loading ? null : _login,
                            isLoading: _loading,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have access? ", style: DexTypography.bodySmall),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Create Terminal',
                            style: DexTypography.bodySmall.copyWith(
                              color: DexColors.primary,
                              fontWeight: FontWeight.w700,
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
    );
  }
}
