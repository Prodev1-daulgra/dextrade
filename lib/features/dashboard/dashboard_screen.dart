import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/dex_glass_card.dart';
import '../../widgets/animated_counter.dart';
import '../../widgets/pulse_dot.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  bool _hideBalance = false;
  late AnimationController _pulseRingController;

  @override
  void initState() {
    super.initState();
    _pulseRingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseRingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final email = auth.email;
    if (email == null) return const SizedBox();

    final balanceAsync = ref.watch(balanceProvider(email));

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Institutional Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Institutional Matrix', style: DexTypography.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Global protocol status and asset overview',
                      style: DexTypography.bodyLarge,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildVaultStatus(),
                    const SizedBox(width: 16),
                    _buildNodeStatus(),
                  ],
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.05),

            const SizedBox(height: 48),

            // Main Grid
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 800;
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 2, child: _buildBalanceHub(balanceAsync)),
                        const SizedBox(width: 32),
                        Expanded(flex: 1, child: _buildAlphaSentiment()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildBalanceHub(balanceAsync),
                        const SizedBox(height: 32),
                        _buildAlphaSentiment(),
                      ],
                    );
            }),

            const SizedBox(height: 48),

            // Quick Access Matrix
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DexColors.surface,
        border: Border.all(color: DexColors.borderLight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DexColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DexColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.shield, color: DexColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VAULT PROTOCOL', style: DexTypography.label),
              Text(
                'ENCRYPTED & SYNCED',
                style: DexTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNodeStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DexColors.surface,
        border: Border.all(color: DexColors.borderLight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('GLOBAL NODE', style: DexTypography.label),
          Text(
            'OPTIMAL 0ms',
            style: DexTypography.caption.copyWith(
              color: DexColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHub(AsyncValue balanceAsync) {
    return DexGlassCard(
      padding: const EdgeInsets.all(40),
      hasGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        size: 16, color: DexColors.primary),
                    const SizedBox(width: 8),
                    Text('AVAILABLE LIQUIDITY', style: DexTypography.label),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _hideBalance = !_hideBalance),
                icon: Icon(
                  _hideBalance ? Icons.visibility_off : Icons.visibility,
                  color: DexColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          balanceAsync.when(
            data: (bal) => Text(
              _hideBalance ? '••••••' : '\$${(bal?.balanceUsd ?? 0).toStringAsFixed(2)}',
              style: DexTypography.monoHero,
            ),
            loading: () => Text('SYNCING...', style: DexTypography.monoHero),
            error: (_, __) => Text('\$0.00', style: DexTypography.monoHero),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DexColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DexColors.success.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, size: 12, color: DexColors.success),
                    const SizedBox(width: 4),
                    Text('+12.4%', style: DexTypography.label.copyWith(color: DexColors.success)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('PROTOCOL YIELD (24H)', style: DexTypography.label),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      20,
                      (i) => FlSpot(i.toDouble(), 50 + Random().nextDouble() * 50),
                    ),
                    isCurved: true,
                    color: DexColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          DexColors.primary.withValues(alpha: 0.2),
                          DexColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphaSentiment() {
    return Column(
      children: [
        DexGlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MARKET ALPHA', style: DexTypography.label),
                  const Icon(Icons.show_chart, size: 16, color: DexColors.primary),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.72,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: DexColors.primary,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: DexColors.primary.withValues(alpha: 0.5),
                          blurRadius: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('BEAR', style: DexTypography.label.copyWith(color: DexColors.textMuted)),
                  Text('Institutional Greed', style: DexTypography.label.copyWith(color: DexColors.primary)),
                  Text('BULL', style: DexTypography.label.copyWith(color: DexColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DexGlassCard(
          padding: const EdgeInsets.all(32),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: const Icon(Icons.memory, size: 32, color: DexColors.primary),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MASTER NODES', style: DexTypography.h3),
                  const SizedBox(height: 4),
                  Text('3 Nodes Mirroring', style: DexTypography.label.copyWith(color: DexColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.shield, 'Vault', DexColors.primary, '/transactions'),
      (Icons.arrow_downward, 'Deposit', DexColors.primary, '/transactions'),
      (Icons.arrow_upward, 'Withdraw', DexColors.error, '/transactions'),
      (Icons.swap_horiz, 'Trade', Colors.white, '/trade'),
      (Icons.people, 'Mirror', Colors.blue, '/copy-trading'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.sizeOf(context).width > 800 ? 5 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: actions.map((a) {
        return InkWell(
          onTap: () => context.go(a.$4),
          borderRadius: BorderRadius.circular(32),
          child: DexGlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a.$1, color: a.$3, size: 32),
                const SizedBox(height: 16),
                Text(a.$2, style: DexTypography.label.copyWith(color: Colors.white)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
