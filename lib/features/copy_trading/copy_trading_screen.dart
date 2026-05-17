import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/custom_toast.dart';

class CopyTradingScreen extends ConsumerWidget {
  const CopyTradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final email = auth.email ?? '';
    final tradersAsync = ref.watch(copyTradersProvider);
    final copiesAsync = ref.watch(userCopyTradesProvider(email));

    final riskColors = {'low': DexColors.success, 'medium': DexColors.warning, 'high': DexColors.error};

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Copy Trading', style: DexTypography.h1),
                  const SizedBox(height: 4),
                  Text('Mirror institutional execution nodes', style: DexTypography.bodySmall),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: DexColors.success.withValues(alpha: 0.1), border: Border.all(color: DexColors.success.withValues(alpha: 0.2))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: DexColors.success)),
                    const SizedBox(width: 6),
                    Text('NETWORK ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1, color: DexColors.success)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 24),

            tradersAsync.when(
              data: (traders) {
                if (traders.isEmpty) {
                  return Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.people_outlined, size: 48, color: DexColors.textMuted.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No active traders available', style: DexTypography.bodySmall),
                  ])));
                }
                return Column(children: traders.map((trader) {
                  final activeCopies = copiesAsync.valueOrNull ?? [];
                  final activeCopy = activeCopies.where((c) => c.traderId == trader.id).firstOrNull;
                  final riskColor = riskColors[trader.riskLevel] ?? DexColors.warning;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 22,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color(int.parse(trader.avatarColor.replaceFirst('#', '0xFF')))),
                                child: Center(child: Text(trader.traderName.substring(0, 2).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(trader.traderName, style: DexTypography.h3.copyWith(fontSize: 16)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: DexColors.primary.withValues(alpha: 0.1)),
                                    child: Text(trader.specialty ?? 'Institutional', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: DexColors.primary)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: riskColor.withValues(alpha: 0.1)),
                                    child: Text(trader.riskLevel.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: riskColor)),
                                  ),
                                ]),
                              ])),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _StatCol('Return', '+${trader.totalProfitPct.toStringAsFixed(1)}%', DexColors.success),
                              _StatCol('Win Rate', '${trader.winRate.toStringAsFixed(0)}%', DexColors.textPrimary),
                              _StatCol('Followers', '${trader.followers}', DexColors.textPrimary),
                              _StatCol('Min', '\$${trader.minAllocation.toStringAsFixed(0)}', DexColors.textMuted),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (activeCopy != null)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: DexColors.primary.withValues(alpha: 0.08), border: Border.all(color: DexColors.primary.withValues(alpha: 0.2))),
                              child: Row(children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: DexColors.primary)),
                                const SizedBox(width: 8),
                                Text('SYNCED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: DexColors.primary, letterSpacing: 1)),
                                const Spacer(),
                                Text('${activeCopy.profitLoss >= 0 ? '+' : ''}\$${activeCopy.profitLoss.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: activeCopy.profitLoss >= 0 ? DexColors.success : DexColors.error)),
                              ]),
                            )
                          else
                            GlowButton(
                              label: 'Initialize Mirror',
                              icon: Icons.flash_on_rounded,
                              width: double.infinity,
                              onPressed: () async {
                                try {
                                  await ref.read(copyTradeRepoProvider).initializeMirror(email, trader);
                                  ref.invalidate(userCopyTradesProvider(email));
                                  if (context.mounted) DexToast.show(context, 'Mirror initialized successfully!', type: ToastType.success);
                                } catch (e) {
                                  if (context.mounted) DexToast.show(context, e.toString(), type: ToastType.error);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList());
              },
              loading: () => Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerLoader(height: 180, borderRadius: 22)))),
              error: (_, __) => const Center(child: Text('Failed to load traders')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCol(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(label, style: DexTypography.label.copyWith(fontSize: 9)),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    ]));
  }
}
