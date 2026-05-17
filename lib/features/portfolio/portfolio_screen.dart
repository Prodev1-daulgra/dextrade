import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final email = auth.email ?? '';
    final balAsync = ref.watch(balanceProvider(email));
    final cryptosAsync = ref.watch(cryptosProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio', style: DexTypography.h1),
            const SizedBox(height: 4),
            Text('Your asset allocation overview', style: DexTypography.bodySmall),
            const SizedBox(height: 24),
            // Balance summary
            balAsync.when(
              data: (bal) => GlassCard(
                borderRadius: 22, padding: const EdgeInsets.all(24),
                child: Row(children: [
                  Expanded(child: _InfoBlock('Total Balance', '\$${(bal?.balanceUsd ?? 0).toStringAsFixed(2)}', DexColors.primary)),
                  Container(width: 1, height: 50, color: DexColors.border),
                  Expanded(child: _InfoBlock('Invested', '\$${(bal?.totalInvested ?? 0).toStringAsFixed(2)}', DexColors.accent)),
                  Container(width: 1, height: 50, color: DexColors.border),
                  Expanded(child: _InfoBlock('P&L', '\$${(bal?.totalProfitLoss ?? 0).toStringAsFixed(2)}', (bal?.totalProfitLoss ?? 0) >= 0 ? DexColors.success : DexColors.error)),
                ]),
              ),
              loading: () => const SizedBox(height: 100),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 24),
            Text('MARKET ASSETS', style: DexTypography.label),
            const SizedBox(height: 12),
            cryptosAsync.when(
              data: (cryptos) => Column(
                children: cryptos.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16), borderRadius: 16,
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Color(int.parse(c.iconColor.replaceFirst('#', '0xFF'))).withValues(alpha: 0.15)),
                        child: Center(child: Text(c.symbol[0], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(int.parse(c.iconColor.replaceFirst('#', '0xFF')))))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.name, style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary, fontWeight: FontWeight.w700)),
                        Text(c.symbol, style: DexTypography.caption),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('\$${c.price.toStringAsFixed(2)}', style: DexTypography.mono.copyWith(fontSize: 14)),
                        Text('${c.isPositive ? '+' : ''}${c.change24h.toStringAsFixed(2)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.isPositive ? DexColors.success : DexColors.error)),
                      ]),
                    ]),
                  ),
                )).toList(),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const Text('Failed to load'),
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
      child: Column(children: [
        Text(label, style: DexTypography.label),
        const SizedBox(height: 8),
        Text(value, style: DexTypography.mono.copyWith(color: color, fontSize: 16)),
      ]),
    );
  }
}
