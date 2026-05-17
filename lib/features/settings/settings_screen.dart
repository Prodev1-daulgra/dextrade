import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Settings', style: DexTypography.h1),
          const SizedBox(height: 4),
          Text('Account configuration', style: DexTypography.bodySmall),
          const SizedBox(height: 24),
          // Profile card
          GlassCard(
            borderRadius: 22, padding: const EdgeInsets.all(24),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: DexColors.primaryGradient)),
                child: Center(child: Text((auth.user?.fullName ?? auth.user?.email ?? 'U')[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(auth.user?.fullName ?? 'User', style: DexTypography.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(auth.user?.email ?? '', style: DexTypography.caption),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: DexColors.primary.withValues(alpha: 0.1)),
                  child: Text(auth.user?.role.toUpperCase() ?? 'USER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: DexColors.primary, letterSpacing: 1)),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 32),
          GlowButton(
            label: 'Sign Out',
            isPrimary: false,
            icon: Icons.logout_rounded,
            width: double.infinity,
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ]),
      ),
    );
  }
}
