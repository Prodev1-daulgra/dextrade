import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_counter.dart';
import '../../widgets/pulse_dot.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/crypto_icon.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final email = auth.email;
    if (email == null) return const SizedBox();

    final balanceAsync = ref.watch(balanceProvider(email));
    final cryptosAsync = ref.watch(cryptosProvider);
    final txAsync = ref.watch(transactionsProvider(email));

    // Determine if user has any funds/history
    final bool isEmptyState = balanceAsync.value?.balanceUsd == 0 && (txAsync.value?.isEmpty ?? true);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alpha Node', style: DexTypography.label.copyWith(color: DexColors.primary)),
                      const SizedBox(height: 2),
                      Text(
                        auth.user?.fullName ?? email.split('@')[0],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const PulseDot(color: DexColors.success),
                    const SizedBox(width: 8),
                    Text('SYNCED', style: DexTypography.label.copyWith(color: DexColors.success)),
                  ],
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
            const SizedBox(height: 28),

            // Balance Hero Card
            GlassCard(
              padding: const EdgeInsets.all(28),
              borderRadius: 28,
              borderColor: DexColors.primary.withValues(alpha: 0.2),
              child: Stack(
                children: [
                  // Ambient background glow for the card
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DexColors.primary.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: DexColors.primary.withValues(alpha: 0.2),
                            blurRadius: 50,
                            spreadRadius: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: DexColors.primary.withValues(alpha: 0.1),
                              border: Border.all(color: DexColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.account_balance_wallet_rounded, size: 14, color: DexColors.primary),
                                const SizedBox(width: 6),
                                Text('AVAILABLE LIQUIDITY', style: DexTypography.label.copyWith(color: DexColors.primary)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _hideBalance = !_hideBalance),
                            child: Icon(
                              _hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 20, color: DexColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      balanceAsync.when(
                        data: (bal) => _hideBalance
                            ? Text('••••••', style: DexTypography.monoHero)
                            : AnimatedCounter(value: bal?.balanceUsd ?? 0, style: DexTypography.monoHero),
                        loading: () => const ShimmerLoader(height: 52, width: 200),
                        error: (_, __) => Text('\$0.00', style: DexTypography.monoHero),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: isEmptyState ? DexColors.textMuted.withValues(alpha: 0.1) : DexColors.success.withValues(alpha: 0.1),
                              border: Border.all(color: isEmptyState ? DexColors.textMuted.withValues(alpha: 0.2) : DexColors.success.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isEmptyState ? Icons.trending_flat_rounded : Icons.trending_up_rounded, size: 12, color: isEmptyState ? DexColors.textMuted : DexColors.success),
                                const SizedBox(width: 4),
                                Text(isEmptyState ? '0.0%' : '+12.4%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isEmptyState ? DexColors.textMuted : DexColors.success)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('PROTOCOL YIELD (24H)', style: DexTypography.label),
                        ],
                      ),
                      
                      if (!isEmptyState) ...[
                        const SizedBox(height: 20),
                        // Mini chart
                        SizedBox(
                          height: 80,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(20, (i) => FlSpot(i.toDouble(), 50 + Random().nextDouble() * 50)),
                                  isCurved: true,
                                  color: DexColors.primary,
                                  barWidth: 2.5,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [DexColors.primary.withValues(alpha: 0.2), DexColors.primary.withValues(alpha: 0.0)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ).animate().fade(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),

            // Quick Actions
            Text('QUICK ACTIONS', style: DexTypography.label),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickAction(icon: Icons.arrow_downward_rounded, label: 'Deposit', color: DexColors.success, onTap: () => context.go('/transactions')),
                const SizedBox(width: 10),
                _QuickAction(icon: Icons.arrow_upward_rounded, label: 'Withdraw', color: DexColors.error, onTap: () => context.go('/transactions')),
                const SizedBox(width: 10),
                _QuickAction(icon: Icons.swap_horiz_rounded, label: 'Trade', color: DexColors.accent, onTap: () => context.go('/trade')),
                const SizedBox(width: 10),
                _QuickAction(icon: Icons.people_rounded, label: 'Mirror', color: DexColors.primary, onTap: () => context.go('/copy-trading')),
              ],
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 28),

            if (isEmptyState) ...[
              // Empty State Guidance
              EmptyStateWidget(
                icon: Icons.rocket_launch_rounded,
                title: 'Initialize Node',
                subtitle: 'Your institutional trading terminal is ready. Deposit liquidity to activate market access and mirror trading.',
                ctaLabel: 'Deposit Liquidity',
                onCtaPressed: () => context.go('/transactions'),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
            ] else ...[
              // Market Overview
              Text('MARKET OVERVIEW', style: DexTypography.label),
              const SizedBox(height: 12),
              cryptosAsync.when(
                data: (cryptos) => Column(
                  children: cryptos.take(5).map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          CryptoIcon(symbol: c.symbol, colorHex: c.iconColor, size: 40),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name, style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary, fontWeight: FontWeight.w700)),
                                Text(c.symbol, style: DexTypography.caption),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${c.price.toStringAsFixed(2)}', style: DexTypography.mono.copyWith(fontSize: 14)),
                              Text(
                                '${c.isPositive ? '+' : ''}${c.change24h.toStringAsFixed(2)}%',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.isPositive ? DexColors.success : DexColors.error),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ).animate().fade(delay: 300.ms),
                loading: () => Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 8), child: ShimmerLoader(height: 68, borderRadius: 16)))),
                error: (_, __) => const Text('Failed to load market data'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 18),
          borderRadius: 18,
          borderColor: color.withValues(alpha: 0.15),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: DexColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
