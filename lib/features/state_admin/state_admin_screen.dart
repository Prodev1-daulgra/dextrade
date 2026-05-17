import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/pulse_dot.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/custom_toast.dart';
import '../../data/models/transaction_model.dart';

class StateAdminScreen extends ConsumerStatefulWidget {
  const StateAdminScreen({super.key});

  @override
  ConsumerState<StateAdminScreen> createState() => _StateAdminScreenState();
}

class _StateAdminScreenState extends ConsumerState<StateAdminScreen> {
  String _tab = 'transactions';

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final email = auth.email ?? '';
    final txAsync = ref.watch(transactionsProvider(email));
    final balAsync = ref.watch(balanceProvider(email));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.tune_rounded, size: 22, color: DexColors.primary),
                    const SizedBox(width: 10),
                    Text('State Admin Portal', style: DexTypography.h1),
                  ]),
                  const SizedBox(height: 6),
                  Text('Manipulate UI states for your account data. Changes propagate in real-time across all devices.', style: DexTypography.bodySmall),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: DexColors.primary.withValues(alpha: 0.08),
                    border: Border.all(color: DexColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const PulseDot(color: DexColors.primary, size: 6),
                    const SizedBox(width: 8),
                    Text('DATA STREAM ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1, color: DexColors.primary)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Simulation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DexColors.warning.withValues(alpha: 0.1),
                border: Border.all(color: DexColors.warning.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: DexColors.warning, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SIMULATION MODE: Pretend you are the backend logic', style: DexTypography.bodyMedium.copyWith(color: DexColors.warning, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Use this portal to test UI/UX states that depend on external data (e.g. approving deposits or tracking portfolio updates) to see how the app reacts in real-time.', style: DexTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // User scope indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: DexColors.surfaceLight,
                border: Border.all(color: DexColors.border),
              ),
              child: Row(children: [
                Icon(Icons.person_outline, size: 14, color: DexColors.textMuted),
                const SizedBox(width: 8),
                Text('SCOPE: ', style: DexTypography.label),
                Text(email, style: DexTypography.label.copyWith(color: DexColors.primary)),
                const Spacer(),
                Text('OWN ACCOUNT ONLY', style: DexTypography.label.copyWith(color: DexColors.warning)),
              ]),
            ),
            const SizedBox(height: 24),

            // Tab selector
            Row(children: [
              _TabChip('transactions', 'Transaction States', Icons.receipt_long_rounded, _tab == 'transactions', () => setState(() => _tab = 'transactions')),
              const SizedBox(width: 10),
              _TabChip('balance', 'Balance State', Icons.account_balance_wallet_rounded, _tab == 'balance', () => setState(() => _tab = 'balance')),
              const SizedBox(width: 10),
              _TabChip('sync', 'Data Sync', Icons.sync_rounded, _tab == 'sync', () => setState(() => _tab = 'sync')),
            ]),
            const SizedBox(height: 24),

            // Content
            if (_tab == 'transactions')
              _TransactionStates(email: email, txAsync: txAsync, ref: ref),
            if (_tab == 'balance')
              _BalanceState(balAsync: balAsync, ref: ref),
            if (_tab == 'sync')
              _DataSync(email: email),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _TabChip(this.id, this.label, this.icon, this.isActive, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? DexColors.primary.withValues(alpha: 0.12) : DexColors.surfaceLight,
          border: Border.all(color: isActive ? DexColors.primary.withValues(alpha: 0.3) : DexColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isActive ? DexColors.primary : DexColors.textMuted),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? DexColors.primary : DexColors.textMuted)),
        ]),
      ),
    );
  }
}

class _TransactionStates extends StatelessWidget {
  final String email;
  final AsyncValue<List<TransactionModel>> txAsync;
  final WidgetRef ref;
  const _TransactionStates({required this.email, required this.txAsync, required this.ref});

  @override
  Widget build(BuildContext context) {
    return txAsync.when(
      data: (txns) {
        final pending = txns.where((t) => t.isPending).toList();
        final recent = txns.take(20).toList();

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Pending actions
          if (pending.isNotEmpty) ...[
            Row(children: [
              Text('PENDING STATE TRANSITIONS', style: DexTypography.label.copyWith(color: DexColors.warning)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: DexColors.warning.withValues(alpha: 0.15)),
                child: Text('${pending.length}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: DexColors.warning)),
              ),
            ]),
            const SizedBox(height: 12),
            ...pending.map((tx) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                borderRadius: 18, padding: const EdgeInsets.all(18),
                borderColor: DexColors.warning.withValues(alpha: 0.2),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: (tx.isDeposit ? DexColors.success : DexColors.error).withValues(alpha: 0.12)),
                      child: Icon(tx.isDeposit ? Icons.arrow_downward : Icons.arrow_upward, size: 18, color: tx.isDeposit ? DexColors.success : DexColors.error),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${tx.type[0].toUpperCase()}${tx.type.substring(1)} Request', style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary, fontWeight: FontWeight.w700)),
                      Text('ID: ${tx.id.substring(0, 8)}...', style: DexTypography.caption.copyWith(fontFamily: 'monospace')),
                    ])),
                    Text('\$${tx.amount.toStringAsFixed(2)}', style: DexTypography.mono.copyWith(fontSize: 16)),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: DexColors.background.withValues(alpha: 0.5)),
                    child: Row(children: [
                      Text('status: ', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: DexColors.textMuted)),
                      const StatusBadge(status: 'pending'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 14, color: DexColors.textMuted),
                      const SizedBox(width: 8),
                      Text('→  ', style: TextStyle(fontSize: 10, color: DexColors.textMuted)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: GlowButton(
                      label: 'Set: Approved',
                      onPressed: () async {
                        try {
                          await ref.read(txRepoProvider).approveTransaction(tx.id);
                          // It's a StreamProvider so it updates automatically
                          if (context.mounted) DexToast.show(context, 'Transaction Approved', type: ToastType.success);
                        } catch (e) {
                          if (context.mounted) DexToast.show(context, e.toString(), type: ToastType.error);
                        }
                      },
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: GlowButton(
                      label: 'Set: Failed',
                      isPrimary: false,
                      onPressed: () async {
                        try {
                          await ref.read(txRepoProvider).rejectTransaction(tx.id);
                          // StreamProvider auto updates
                          if (context.mounted) DexToast.show(context, 'Transaction Failed', type: ToastType.success);
                        } catch (e) {
                          if (context.mounted) DexToast.show(context, e.toString(), type: ToastType.error);
                        }
                      },
                    )),
                  ]),
                ]),
              ),
            )),
            const SizedBox(height: 20),
          ],

          Text('RECENT STATE LOG', style: DexTypography.label),
          const SizedBox(height: 12),
          ...recent.map((tx) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: DexColors.surfaceLight, border: Border.all(color: DexColors.border)),
              child: Row(children: [
                Text(tx.type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: DexColors.textMuted)),
                const SizedBox(width: 10),
                Text('\$${tx.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: DexColors.textPrimary)),
                const Spacer(),
                StatusBadge(status: tx.status, fontSize: 8),
              ]),
            ),
          )),
        ]);
      },
      loading: () => Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 10), child: ShimmerLoader(height: 100, borderRadius: 18)))),
      error: (_, __) => const Text('Error loading transactions'),
    );
  }
}

class _BalanceState extends StatelessWidget {
  final AsyncValue balAsync;
  final WidgetRef ref;
  const _BalanceState({required this.balAsync, required this.ref});

  @override
  Widget build(BuildContext context) {
    return balAsync.when(
      data: (bal) => GlassCard(
        borderRadius: 22, padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CURRENT BALANCE STATE', style: DexTypography.label.copyWith(color: DexColors.primary)),
          const SizedBox(height: 20),
          _StateRow('balance_usd', '\$${(bal?.balanceUsd ?? 0).toStringAsFixed(2)}'),
          _StateRow('total_invested', '\$${(bal?.totalInvested ?? 0).toStringAsFixed(2)}'),
          _StateRow('total_profit_loss', '\$${(bal?.totalProfitLoss ?? 0).toStringAsFixed(2)}'),
          _StateRow('user_email', bal?.userEmail ?? '—'),
          _StateRow('updated_at', bal?.updatedAt.toIso8601String() ?? '—'),
          const SizedBox(height: 16),
          Text('Balance state is derived from approved transactions.\nApprove a pending transaction to see balance state change.', style: DexTypography.caption),
        ]),
      ),
      loading: () => const ShimmerLoader(height: 200, borderRadius: 22),
      error: (_, __) => const Text('Error'),
    );
  }
}

class _StateRow extends StatelessWidget {
  final String rowKey;
  final String value;
  const _StateRow(this.rowKey, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(child: Text(rowKey, style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: DexColors.textMuted))),
        Text(value, style: TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w800, color: DexColors.textPrimary)),
      ]),
    );
  }
}

class _DataSync extends StatelessWidget {
  final String email;
  const _DataSync({required this.email});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22, padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const PulseDot(color: DexColors.success, size: 8),
          const SizedBox(width: 10),
          Text('REALTIME SYNC STATUS', style: DexTypography.label.copyWith(color: DexColors.success)),
        ]),
        const SizedBox(height: 20),
        _SyncRow('Supabase Realtime', 'Connected', DexColors.success),
        _SyncRow('Transaction Channel', 'Subscribed', DexColors.success),
        _SyncRow('Balance Channel', 'Subscribed', DexColors.success),
        _SyncRow('Scope', email, DexColors.primary),
        const SizedBox(height: 16),
        Text('All state changes made in this portal propagate to your mobile app and other web sessions via Supabase Realtime subscriptions.', style: DexTypography.caption),
      ]),
    );
  }
}

class _SyncRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SyncRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DexColors.textMuted))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.withValues(alpha: 0.1), border: Border.all(color: color.withValues(alpha: 0.2))),
          child: Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
        ),
      ]),
    );
  }
}
