import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/pulse_dot.dart';

class SuperadminScreen extends ConsumerWidget {
  const SuperadminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // Hard guard: only tonyokezie10@gmail.com
    if (!auth.isSuperAdmin) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 48, color: DexColors.error),
              const SizedBox(height: 16),
              Text(
                'ACCESS DENIED',
                style: DexTypography.h2.copyWith(color: DexColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                'Superadmin access restricted',
                style: DexTypography.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    final usersAsync = ref.watch(allUsersProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 22,
                  color: DexColors.error,
                ),
                const SizedBox(width: 10),
                Text('Superadmin', style: DexTypography.h1),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Global platform management • ${auth.email}',
              style: DexTypography.bodySmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: DexColors.error.withValues(alpha: 0.08),
                border: Border.all(
                  color: DexColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PulseDot(color: DexColors.error, size: 6),
                  const SizedBox(width: 8),
                  Text(
                    'ELEVATED PRIVILEGES',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: DexColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('ALL USERS', style: DexTypography.label),
            const SizedBox(height: 12),
            usersAsync.when(
              data: (users) => Column(
                children: users
                    .map(
                      (u) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: u.isAdmin
                                      ? DexColors.error.withValues(alpha: 0.15)
                                      : DexColors.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                ),
                                child: Center(
                                  child: Text(
                                    (u.fullName ?? u.email)[0].toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: u.isAdmin
                                          ? DexColors.error
                                          : DexColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.fullName ?? u.email.split('@')[0],
                                      style: DexTypography.bodyMedium.copyWith(
                                        color: DexColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(u.email, style: DexTypography.caption),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color:
                                      (u.status == 'active'
                                              ? DexColors.success
                                              : DexColors.error)
                                          .withValues(alpha: 0.1),
                                ),
                                child: Text(
                                  u.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: u.status == 'active'
                                        ? DexColors.success
                                        : DexColors.error,
                                  ),
                                ),
                              ),
                              if (!u.isSuperAdmin) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: DexColors.error.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  tooltip: 'Delete user',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete User'),
                                        content: Text(
                                          'Delete ${u.email}? This cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: DexColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref
                                          .read(userRepoProvider)
                                          .deleteUser(u.id);
                                      ref.invalidate(allUsersProvider);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              loading: () => Column(
                children: List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShimmerLoader(height: 80, borderRadius: 16),
                  ),
                ),
              ),
              error: (_, __) => const Text('Failed to load users'),
            ),
          ],
        ),
      ),
    );
  }
}
