import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/transaction_status_modal.dart';
import '../../data/models/transaction_model.dart';
import '../../widgets/status_badge.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filter = 'all';
  bool _showDeposit = false;
  bool _showWithdraw = false;
  final _amountCtrl = TextEditingController();
  final _walletCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _walletCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final email = auth.email;
    if (email == null) return const SizedBox();
    final txAsync = ref.watch(transactionsProvider(email));

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transactions', style: DexTypography.h1),
                const SizedBox(height: 4),
                Text('Your complete transaction history', style: DexTypography.bodySmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlowButton(
                        label: 'Deposit',
                        icon: Icons.arrow_downward_rounded,
                        onPressed: () => setState(() { _showDeposit = true; _showWithdraw = false; }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowButton(
                        label: 'Withdraw',
                        icon: Icons.arrow_upward_rounded,
                        isPrimary: false,
                        onPressed: () => setState(() { _showWithdraw = true; _showDeposit = false; }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['all', 'deposit', 'withdrawal', 'buy', 'sell'].map((f) {
                      final isActive = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isActive ? DexColors.primary.withValues(alpha: 0.12) : DexColors.surfaceLight,
                              border: Border.all(color: isActive ? DexColors.primary.withValues(alpha: 0.3) : DexColors.border),
                            ),
                            child: Text(
                              f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? DexColors.primary : DexColors.textMuted),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Deposit/Withdraw Sheet
          if (_showDeposit || _showWithdraw)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                borderColor: _showDeposit ? DexColors.success.withValues(alpha: 0.3) : DexColors.error.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_showDeposit ? 'DEPOSIT' : 'WITHDRAW', style: DexTypography.label.copyWith(color: _showDeposit ? DexColors.success : DexColors.error)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() { _showDeposit = false; _showWithdraw = false; }),
                          child: const Icon(Icons.close_rounded, size: 20, color: DexColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: DexTypography.monoLarge,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '\$ ',
                        prefixStyle: DexTypography.monoLarge.copyWith(color: DexColors.textMuted),
                      ),
                    ),
                    if (_showWithdraw) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _walletCtrl,
                        style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Wallet address'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    GlowButton(
                      label: _showDeposit ? 'Submit Deposit' : 'Submit Withdrawal',
                      isLoading: _submitting,
                      width: double.infinity,
                      onPressed: () => _submit(email),
                    ),
                  ],
                ),
              ),
            ),

          // Transaction List
          Expanded(
            child: txAsync.when(
              data: (txns) {
                final filtered = _filter == 'all' ? txns : txns.where((t) => t.type == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 48, color: DexColors.textMuted.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('No transactions found', style: DexTypography.bodySmall),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final tx = filtered[i];
                    final isDeposit = tx.type == 'deposit';
                    final isSell = tx.type == 'sell' || tx.type == 'stock_sell';
                    final color = isDeposit || isSell ? DexColors.success : tx.type == 'withdrawal' ? DexColors.error : DexColors.accent;
                    final icon = isDeposit ? Icons.arrow_downward_rounded : tx.type == 'withdrawal' ? Icons.arrow_upward_rounded : Icons.swap_horiz_rounded;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: color.withValues(alpha: 0.12),
                              ),
                              child: Icon(icon, size: 20, color: color),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx.type[0].toUpperCase() + tx.type.substring(1), style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(tx.createdAt),
                                    style: DexTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${tx.amount.toStringAsFixed(2)}', style: DexTypography.mono.copyWith(fontSize: 14)),
                                const SizedBox(height: 4),
                                StatusBadge(status: tx.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: List.generate(4, (_) => const Padding(padding: EdgeInsets.only(bottom: 8), child: ShimmerLoader(height: 68, borderRadius: 16)))),
              ),
              error: (_, __) => const Center(child: Text('Failed to load transactions')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(String email) async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(txRepoProvider);
      TransactionModel tx;
      if (_showDeposit) {
        tx = await repo.createDeposit(email, amount);
      } else {
        if (_walletCtrl.text.isEmpty) return;
        tx = await repo.createWithdrawal(email, amount, _walletCtrl.text.trim());
      }
      _amountCtrl.clear();
      _walletCtrl.clear();
      setState(() { _showDeposit = false; _showWithdraw = false; });
      
      // We don't need to invalidate transactionsProvider because it's a StreamProvider now
      
      if (mounted) {
        DexToast.show(context, 'Request initialized. Opening terminal...', type: ToastType.info);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => TransactionStatusModal(email: email, transactionId: tx.id),
        );
      }
    } catch (e) {
      if (mounted) {
        DexToast.show(context, e.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
