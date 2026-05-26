import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../data/models/app_notification_model.dart';
import '../../providers/providers.dart';
import '../dex_shockwave_loader.dart';

class NotificationInboxSheet extends ConsumerWidget {
  const NotificationInboxSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const NotificationInboxSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final email = auth.email;
    if (email == null) return const SizedBox();

    final notifsAsync = ref.watch(appNotificationsProvider(email));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF06060C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: [
                Text(
                  'SIGNAL INBOX',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: DexColors.textMuted),
                ),
              ],
            ),
          ),
          Flexible(
            child: notifsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(48),
                    child: Column(
                      children: [
                        DexShockwaveLoader(size: 72),
                        SizedBox(height: 24),
                        Text(
                          'No signals yet',
                          style: TextStyle(color: DexColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _NotificationTile(
                    n: list[i],
                    onTap: () {
                      ref
                          .read(microFeaturesRepoProvider)
                          .markNotificationRead(list[i].id);
                      ref.invalidate(appNotificationsProvider(email));
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: DexShockwaveLoader(size: 72, brandLabel: 'Sync'),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Deploy micro_features_v1.sql for notification history.',
                  style: TextStyle(color: DexColors.textMuted, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel n;
  final VoidCallback onTap;

  const _NotificationTile({required this.n, required this.onTap});

  Color get _accent {
    switch (n.kind) {
      case 'trade':
        return DexColors.accent;
      case 'deposit':
        return DexColors.success;
      case 'mirror':
        return DexColors.primary;
      default:
        return DexColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: n.isRead
              ? Colors.white.withValues(alpha: 0.02)
              : _accent.withValues(alpha: 0.08),
          border: Border.all(
            color: n.isRead
                ? Colors.white.withValues(alpha: 0.05)
                : _accent.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.bolt_rounded, size: 18, color: _accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: DexColors.textSecondary,
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
}
