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

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

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
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DexColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: DexColors.primaryGradient),
                    boxShadow: [BoxShadow(color: DexColors.primary.withValues(alpha: 0.3), blurRadius: 30)],
                  ),
                  child: const Center(child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28))),
                ),
                const SizedBox(height: 24),
                Text('CREATE TERMINAL', style: DexTypography.h1.copyWith(letterSpacing: 3)),
                const SizedBox(height: 8),
                Text('Join the Dextrade network', style: DexTypography.bodySmall),
                const SizedBox(height: 48),
                GlassCard(
                  padding: const EdgeInsets.all(28),
                  borderRadius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('REGISTER', style: DexTypography.label.copyWith(color: DexColors.primary)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameCtrl,
                        style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Full name (optional)',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: DexColors.textMuted),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          hintText: 'Password (6+ characters)',
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
                      const SizedBox(height: 28),
                      GlowButton(
                        label: 'Initialize Terminal',
                        onPressed: _loading ? null : _register,
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
                    Text('Already have access? ', style: DexTypography.bodySmall),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Sign In', style: DexTypography.bodySmall.copyWith(color: DexColors.primary, fontWeight: FontWeight.w700)),
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
}
