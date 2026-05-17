import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/dex_colors.dart';
import '../core/theme/dex_typography.dart';
import '../providers/providers.dart';

class TransactionStatusModal extends ConsumerWidget {
  final String email;
  final String transactionId;

  const TransactionStatusModal({
    super.key,
    required this.email,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the transactions stream for this user.
    final txAsync = ref.watch(transactionsProvider(email));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: DexColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: DexColors.border, width: 1),
          boxShadow: [
            BoxShadow(color: DexColors.primary.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: -10),
          ],
        ),
        child: txAsync.when(
          data: (transactions) {
            final tx = transactions.where((t) => t.id == transactionId).firstOrNull;
            if (tx == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final isPending = tx.status == 'pending';
            final isApproved = tx.status == 'approved' || tx.status == 'completed';
            final isRejected = tx.status == 'rejected';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Status Icon
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background pulse rings
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isApproved ? DexColors.success.withValues(alpha: 0.1) : 
                                 isRejected ? DexColors.error.withValues(alpha: 0.1) : 
                                 DexColors.warning.withValues(alpha: 0.1),
                        ),
                      ).animate(
                        onPlay: (controller) => isPending ? controller.repeat(reverse: true) : controller.forward(),
                      ).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1500.ms, curve: Curves.easeInOut),

                      // The Icon itself
                      if (isPending)
                        Icon(Icons.hourglass_top_rounded, size: 48, color: DexColors.warning)
                            .animate(onPlay: (controller) => controller.repeat())
                            .rotate(duration: 2000.ms, curve: Curves.easeInOut)
                      else if (isApproved)
                        Container(
                          width: 64, height: 64,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: DexColors.success),
                          child: const Icon(Icons.check_rounded, size: 40, color: Colors.white),
                        ).animate().scale(curve: Curves.elasticOut, duration: 600.ms)
                      else
                        Container(
                          width: 64, height: 64,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: DexColors.error),
                          child: const Icon(Icons.close_rounded, size: 40, color: Colors.white),
                        ).animate().shake(curve: Curves.easeInOut, duration: 400.ms)
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Status Text
                Text(
                  isPending ? 'Processing' : isApproved ? 'Successful' : 'Failed',
                  style: DexTypography.h2.copyWith(
                    color: isApproved ? DexColors.success : isRejected ? DexColors.error : DexColors.warning,
                  ),
                ).animate(key: ValueKey(tx.status)).fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),

                // Amount
                Text(
                  '\$${tx.amount.toStringAsFixed(2)}',
                  style: DexTypography.monoLarge,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  isPending 
                    ? 'Awaiting network confirmation...' 
                    : isApproved 
                      ? 'Your balance has been updated.' 
                      : 'The transaction was rejected.',
                  style: DexTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate(key: ValueKey(tx.status + '_msg')).fadeIn(),

                const SizedBox(height: 28),

                // Close Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: DexColors.surfaceLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Close Window', style: DexTypography.button),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 200, 
            child: Center(child: CircularProgressIndicator(color: DexColors.primary)),
          ),
          error: (_, __) => const Text('Error loading status'),
        ),
      ),
    );
  }
}
