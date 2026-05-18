import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../widgets/empty_state_widget.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filter = 'all';
  bool _showDeposit = false;
  bool _showWithdraw = false;

  // Wizard State
  int _depositStep = 1; // 1: Network, 2: Amount, 3: Confirm
  String _selectedNetwork = 'ERC20';
  final _amountCtrl = TextEditingController();
  final _walletCtrl = TextEditingController();
  bool _submitting = false;

  final List<String> _networks = [
    'ERC20 (Ethereum)',
    'TRC20 (Tron)',
    'BEP20 (BNB Smart Chain)',
    'SOL (Solana)',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _walletCtrl.dispose();
    super.dispose();
  }

  void _resetForms() {
    setState(() {
      _showDeposit = false;
      _showWithdraw = false;
      _depositStep = 1;
      _amountCtrl.clear();
      _walletCtrl.clear();
    });
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
                Text(
                  'Liquidity Hub',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ).animate().fade().slideY(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  'Manage terminal capital & transfers',
                  style: DexTypography.bodySmall,
                ).animate().fade(delay: 100.ms),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GlowButton(
                        label: 'Deposit',
                        icon: Icons.arrow_downward_rounded,
                        onPressed: () => setState(() {
                          _showDeposit = true;
                          _showWithdraw = false;
                          _depositStep = 1;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowButton(
                        label: 'Withdraw',
                        icon: Icons.arrow_upward_rounded,
                        isPrimary: false,
                        onPressed: () => setState(() {
                          _showWithdraw = true;
                          _showDeposit = false;
                        }),
                      ),
                    ),
                  ],
                ).animate().fade(delay: 200.ms),
                const SizedBox(height: 20),
                // Filter chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['all', 'deposit', 'withdrawal', 'buy', 'sell']
                        .map((f) {
                          final isActive = _filter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isActive
                                      ? DexColors.primary.withValues(
                                          alpha: 0.12,
                                        )
                                      : DexColors.surfaceLight,
                                  border: Border.all(
                                    color: isActive
                                        ? DexColors.primary.withValues(
                                            alpha: 0.3,
                                          )
                                        : DexColors.border,
                                  ),
                                ),
                                child: Text(
                                  f == 'all'
                                      ? 'All'
                                      : f[0].toUpperCase() + f.substring(1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? DexColors.primary
                                        : DexColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ).animate().fade(delay: 300.ms),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Deposit Wizard
          if (_showDeposit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildDepositWizard(email),
            ).animate().fade().scale(begin: const Offset(0.95, 0.95)),

          // Withdrawal Form
          if (_showWithdraw)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildWithdrawalForm(email),
            ).animate().fade().scale(begin: const Offset(0.95, 0.95)),

          // Transaction List
          Expanded(
            child: txAsync.when(
              data: (txns) {
                final filtered = _filter == 'all'
                    ? txns
                    : txns.where((t) => t.type == _filter).toList();
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.receipt_long_rounded,
                    title: 'No Logs Found',
                    subtitle:
                        'Terminal execution history is empty for the selected filter.',
                  ).animate().fade(delay: 400.ms);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final tx = filtered[i];
                    final isDeposit = tx.type == 'deposit';
                    final isSell = tx.type == 'sell' || tx.type == 'stock_sell';
                    final color = isDeposit || isSell
                        ? DexColors.success
                        : tx.type == 'withdrawal'
                        ? DexColors.error
                        : DexColors.accent;
                    final icon = isDeposit
                        ? Icons.arrow_downward_rounded
                        : tx.type == 'withdrawal'
                        ? Icons.arrow_upward_rounded
                        : Icons.swap_horiz_rounded;

                    return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            borderRadius: 16,
                            borderColor: Colors.white.withValues(alpha: 0.04),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: color.withValues(alpha: 0.12),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Icon(icon, size: 20, color: color),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.type[0].toUpperCase() +
                                            tx.type.substring(1),
                                        style: DexTypography.bodyMedium
                                            .copyWith(
                                              color: DexColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
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
                                    Text(
                                      '\$${tx.amount.toStringAsFixed(2)}',
                                      style: DexTypography.mono.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    StatusBadge(status: tx.status),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fade(delay: Duration(milliseconds: 300 + (i * 50)))
                        .slideY(begin: 0.1);
                  },
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: List.generate(
                    4,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: ShimmerLoader(height: 68, borderRadius: 16),
                    ),
                  ),
                ),
              ),
              error: (_, __) =>
                  const Center(child: Text('Failed to load transaction nodes')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositWizard(String email) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: DexColors.success.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'INITIALIZE DEPOSIT NODE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: DexColors.successGlow,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _resetForms,
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: DexColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Wizard Progress Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  color: _depositStep >= 1
                      ? DexColors.success
                      : DexColors.border,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  color: _depositStep >= 2
                      ? DexColors.success
                      : DexColors.border,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  color: _depositStep >= 3
                      ? DexColors.success
                      : DexColors.border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Step 1: Network Selection
          if (_depositStep == 1) ...[
            Text(
              'Select Target Network',
              style: DexTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._networks.map(
              (n) => GestureDetector(
                onTap: () => setState(() => _selectedNetwork = n),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedNetwork == n
                          ? DexColors.success
                          : DexColors.border,
                    ),
                    color: _selectedNetwork == n
                        ? DexColors.success.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hub_rounded,
                        size: 18,
                        color: _selectedNetwork == n
                            ? DexColors.success
                            : DexColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        n,
                        style: TextStyle(
                          color: _selectedNetwork == n
                              ? Colors.white
                              : DexColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedNetwork == n)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: DexColors.success,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlowButton(
              label: 'Continue',
              onPressed: () => setState(() => _depositStep = 2),
              width: double.infinity,
              isPrimary: true,
              icon: Icons.arrow_forward_rounded,
            ),
          ],

          // Step 2: Amount Entry
          if (_depositStep == 2) ...[
            Text(
              'Specify Transfer Volume',
              style: DexTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 24,
                    color: Colors.white30,
                  ),
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 24,
                    color: DexColors.success,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlowButton(
                    label: 'Back',
                    onPressed: () => setState(() => _depositStep = 1),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlowButton(
                    label: 'Continue',
                    onPressed: () {
                      final val = double.tryParse(_amountCtrl.text);
                      if (val != null && val > 0) {
                        setState(() => _depositStep = 3);
                      } else {
                        DexToast.showPushNotification(
                          context,
                          title: 'Error',
                          body: 'Invalid deposit volume',
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],

          // Step 3: Confirmation & Wallet Generation
          if (_depositStep == 3) ...[
            Text(
              'Initiate Node Sync',
              style: DexTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DexColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DexColors.success.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Volume', style: DexTypography.caption),
                      Text(
                        '\$${_amountCtrl.text}',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Network', style: DexTypography.caption),
                      Text(
                        _selectedNetwork,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlowButton(
                    label: 'Back',
                    onPressed: () => setState(() => _depositStep = 2),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlowButton(
                    label: 'Confirm Transfer',
                    isLoading: _submitting,
                    onPressed: () => _submit(email),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(String email) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: DexColors.error.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'WITHDRAWAL PROTOCOL',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: DexColors.errorGlow,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _resetForms,
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: DexColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('Volume to Extract', style: DexTypography.caption),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 24,
                  color: Colors.white30,
                ),
                prefixText: '\$ ',
                prefixStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 24,
                  color: DexColors.error,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text('Target Wallet Node', style: DexTypography.caption),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: TextField(
              controller: _walletCtrl,
              style: DexTypography.bodyMedium.copyWith(
                color: DexColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '0x...',
                border: InputBorder.none,
                icon: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: DexColors.textMuted,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          GlowButton(
            label: 'Execute Withdrawal',
            isLoading: _submitting,
            width: double.infinity,
            onPressed: () => _submit(email),
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
        // Mock generating wallet logic here - you can pass network inside the transaction metadata in the future
        tx = await repo.createDeposit(email, amount);
      } else {
        if (_walletCtrl.text.isEmpty) {
          DexToast.showPushNotification(
            context,
            title: 'Error',
            body: 'Wallet address required',
          );
          return;
        }
        tx = await repo.createWithdrawal(
          email,
          amount,
          _walletCtrl.text.trim(),
        );
      }

      _resetForms();

      if (mounted) {
        DexToast.showPushNotification(
          context,
          title: 'Syncing...',
          body: 'Transfer Protocol Initiated. Syncing terminal...',
        );
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) =>
              TransactionStatusModal(email: email, transactionId: tx.id),
        );
      }
    } catch (e) {
      if (mounted) {
        DexToast.showPushNotification(
          context,
          title: 'Error',
          body: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
