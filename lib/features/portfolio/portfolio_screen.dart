import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/crypto_icon.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final email = auth.email ?? '';
    final balAsync = ref.watch(balanceProvider(email));
    final cryptosAsync = ref.watch(cryptosProvider);
    final portfolioAsync = ref.watch(portfolioProvider(email));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ).animate().fade().slideY(begin: -0.2),
            const SizedBox(height: 4),
            Text('Your asset allocation overview', style: DexTypography.bodySmall).animate().fade(delay: 100.ms),
            const SizedBox(height: 24),
            
            // Balance summary
            balAsync.when(
              data: (bal) {
                final balance = bal?.balanceUsd ?? 0.0;
                final invested = bal?.totalInvested ?? 0.0;
                final pnl = bal?.totalProfitLoss ?? 0.0;
                
                return GlassCard(
                  borderRadius: 22, 
                  padding: const EdgeInsets.all(24),
                  borderColor: Colors.white.withValues(alpha: 0.04),
                  child: Row(children: [
                    Expanded(child: _InfoBlock('Total Balance', '\$${balance.toStringAsFixed(2)}', DexColors.primary)),
                    Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.08)),
                    Expanded(child: _InfoBlock('Invested', '\$${invested.toStringAsFixed(2)}', DexColors.accent)),
                    Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.08)),
                    Expanded(child: _InfoBlock('P&L', '${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)}', pnl >= 0 ? DexColors.success : DexColors.error)),
                  ]),
                ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: ShimmerLoader(height: 100, borderRadius: 22),
              ),
              error: (_, __) => const SizedBox(),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'ALLOCATED ASSETS',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: DexColors.primaryGlow,
                letterSpacing: 1.0,
              ),
            ).animate().fade(delay: 300.ms),
            const SizedBox(height: 16),
            
            portfolioAsync.when(
              data: (portfolioList) {
                return cryptosAsync.when(
                  data: (cryptos) {
                    if (portfolioList.isEmpty) {
                      return const EmptyStateWidget(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'No Active Holdings',
                        subtitle: 'Initialize a node in the Trade terminal to allocate assets to your portfolio.',
                      ).animate().fade(delay: 400.ms);
                    }
                    
                    return Column(
                      children: portfolioList.asMap().entries.map((entry) {
                        final i = entry.key;
                        final p = entry.value;
                        // Find matching crypto data for current price, icon, etc.
                        final crypto = cryptos.firstWhere(
                          (c) => c.symbol == p.cryptoSymbol,
                          orElse: () => cryptos.first,
                        );
                        
                        final currentValue = p.amount * crypto.price;
                        final investedValue = p.amount * p.avgBuyPrice;
                        final pnl = currentValue - investedValue;
                        final pnlPct = investedValue > 0 ? (pnl / investedValue) * 100 : 0.0;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16), 
                            borderRadius: 16,
                            borderColor: Colors.white.withValues(alpha: 0.04),
                            child: Row(children: [
                              CryptoIcon(symbol: crypto.symbol, colorHex: crypto.iconColor, size: 44),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(crypto.name, style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('${p.amount.toStringAsFixed(4)} ${p.cryptoSymbol}', style: DexTypography.caption),
                                    const SizedBox(width: 8),
                                    Text('Avg \$${p.avgBuyPrice.toStringAsFixed(2)}', style: DexTypography.caption.copyWith(color: DexColors.textMuted)),
                                  ],
                                ),
                              ])),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text('\$${currentValue.toStringAsFixed(2)}', style: DexTypography.mono.copyWith(fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  '${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w800, 
                                    color: pnlPct >= 0 ? DexColors.success : DexColors.error,
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                        ).animate().fade(delay: Duration(milliseconds: 300 + (i * 50))).slideY(begin: 0.1);
                      }).toList(),
                    );
                  },
                  loading: () => Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerLoader(height: 76, borderRadius: 16)))),
                  error: (_, __) => const Text('Failed to load market data', style: TextStyle(color: DexColors.error)),
                );
              },
              loading: () => Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerLoader(height: 76, borderRadius: 16)))),
              error: (_, __) => const Text('Failed to load portfolio nodes', style: TextStyle(color: DexColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoBlock(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DexTypography.caption),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.jetBrainsMono(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
