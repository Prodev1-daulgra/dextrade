import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../widgets/glow_morph_loader.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  bool _hideBalance = false;
  late AnimationController _greetingController;
  late AnimationController _pulseRingController;

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _pulseRingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _pulseRingController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final email = auth.email;
    if (email == null) return const SizedBox();

    final balanceAsync = ref.watch(balanceProvider(email));
    final cryptosAsync = ref.watch(cryptosProvider);
    final txAsync = ref.watch(transactionsProvider(email));

    // Determine if user has any funds/history
    final bool isEmptyState =
        balanceAsync.value?.balanceUsd == 0 && (txAsync.value?.isEmpty ?? true);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Premium Header with Greeting ───
            _buildHeader(auth, isEmptyState),
            const SizedBox(height: 28),

            // ─── Balance Hero Card ───
            _buildBalanceHero(balanceAsync, isEmptyState),
            const SizedBox(height: 24),

            // ─── Quick Actions Grid ───
            _buildQuickActions(context),
            const SizedBox(height: 28),

            if (isEmptyState) ...[
              // ─── Empty State Guidance ───
              _buildOnboardingCard(context),
            ] else ...[
              // ─── Live Activity Feed ───
              _buildLiveActivityHeader(),
              const SizedBox(height: 12),
              _buildRecentActivity(txAsync),
              const SizedBox(height: 28),

              // ─── Market Pulse ───
              _buildMarketPulse(cryptosAsync),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthState auth, bool isEmptyState) {
    final name = auth.user?.fullName ?? auth.email?.split('@')[0] ?? 'Node';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    _getGreeting(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: DexColors.textMuted,
                    ),
                  )
                  .animate(controller: _greetingController)
                  .fade(duration: 600.ms)
                  .slideX(begin: -0.1),
              const SizedBox(height: 4),
              Text(
                    name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  )
                  .animate(controller: _greetingController)
                  .fade(delay: 150.ms, duration: 600.ms)
                  .slideX(begin: -0.1),
            ],
          ),
        ),
        // Live status indicator
        GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              child: AnimatedBuilder(
                animation: _pulseRingController,
                builder: (_, child) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DexColors.success.withValues(
                          alpha: 0.2 + _pulseRingController.value * 0.3,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DexColors.surfaceLight,
                    border: Border.all(color: DexColors.border),
                  ),
                  child: const Center(
                    child: PulseDot(color: DexColors.success, size: 10),
                  ),
                ),
              ),
            )
            .animate(controller: _greetingController)
            .fade(delay: 300.ms)
            .scale(begin: const Offset(0.8, 0.8)),
      ],
    );
  }

  Widget _buildBalanceHero(AsyncValue balanceAsync, bool isEmptyState) {
    return GlassCard(
          padding: const EdgeInsets.all(0),
          borderRadius: 28,
          borderColor: DexColors.primary.withValues(alpha: 0.15),
          child: Stack(
            children: [
              // Ambient glow
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DexColors.primary.withValues(alpha: 0.2),
                        DexColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle bottom-left accent
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DexColors.accent.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: DexColors.primary.withValues(alpha: 0.1),
                            border: Border.all(
                              color: DexColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 14,
                                color: DexColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AVAILABLE LIQUIDITY',
                                style: DexTypography.label.copyWith(
                                  color: DexColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _hideBalance = !_hideBalance);
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _hideBalance
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              key: ValueKey(_hideBalance),
                              size: 20,
                              color: DexColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Balance
                    balanceAsync.when(
                      data: (bal) => _hideBalance
                          ? Text('••••••', style: DexTypography.monoHero)
                          : AnimatedCounter(
                              value: bal?.balanceUsd ?? 0,
                              style: DexTypography.monoHero,
                            ),
                      loading: () =>
                          const ShimmerLoader(height: 52, width: 200),
                      error: (_, __) =>
                          Text('\$0.00', style: DexTypography.monoHero),
                    ),
                    const SizedBox(height: 12),

                    // 24h change indicator
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isEmptyState
                                ? DexColors.textMuted.withValues(alpha: 0.1)
                                : DexColors.success.withValues(alpha: 0.1),
                            border: Border.all(
                              color: isEmptyState
                                  ? DexColors.textMuted.withValues(alpha: 0.2)
                                  : DexColors.success.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEmptyState
                                    ? Icons.trending_flat_rounded
                                    : Icons.trending_up_rounded,
                                size: 14,
                                color: isEmptyState
                                    ? DexColors.textMuted
                                    : DexColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isEmptyState ? '0.0%' : '+12.4%',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isEmptyState
                                      ? DexColors.textMuted
                                      : DexColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'PROTOCOL YIELD (24H)',
                          style: DexTypography.label,
                        ),
                      ],
                    ),

                    if (!isEmptyState) ...[
                      const SizedBox(height: 24),
                      // Mini portfolio sparkline chart
                      SizedBox(
                        height: 80,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  20,
                                  (i) => FlSpot(
                                    i.toDouble(),
                                    50 + Random().nextDouble() * 50,
                                  ),
                                ),
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
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fade(delay: 100.ms)
        .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutCubic);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK ACTIONS', style: DexTypography.label),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickAction(
              icon: Icons.arrow_downward_rounded,
              label: 'Deposit',
              color: DexColors.success,
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/transactions');
              },
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.arrow_upward_rounded,
              label: 'Withdraw',
              color: DexColors.error,
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/transactions');
              },
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.candlestick_chart_rounded,
              label: 'Trade',
              color: DexColors.accent,
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/trade');
              },
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.people_rounded,
              label: 'Mirror',
              color: DexColors.primary,
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/copy-trading');
              },
            ),
          ],
        ).animate().fade(delay: 200.ms),
      ],
    );
  }

  Widget _buildOnboardingCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 24,
      borderColor: DexColors.primary.withValues(alpha: 0.2),
      child: Column(
        children: [
          const GlowMorphLoader(size: 64, glowStrength: 16),
          const SizedBox(height: 24),
          Text(
            'Initialize Your Node',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your institutional trading terminal is online. Deposit liquidity to activate market access, mirror trading, and portfolio analytics.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: DexColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.go('/transactions');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: DexColors.primaryGradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DexColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'DEPOSIT LIQUIDITY',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.15);
  }

  Widget _buildLiveActivityHeader() {
    return Row(
      children: [
        Text('RECENT ACTIVITY', style: DexTypography.label),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: DexColors.success.withValues(alpha: 0.1),
            border: Border.all(color: DexColors.success.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PulseDot(color: DexColors.success, size: 5),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: DexColors.successGlow,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fade(delay: 250.ms);
  }

  Widget _buildRecentActivity(AsyncValue txAsync) {
    return txAsync.when(
      data: (txns) {
        final recent = txns.take(4).toList();
        if (recent.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.receipt_long_rounded,
            title: 'No Activity Yet',
            subtitle: 'Your transaction history will appear here.',
            isSmall: true,
          );
        }
        return Column(
          children: recent.asMap().entries.map((entry) {
            final i = entry.key;
            final tx = entry.value;
            final isDeposit = tx.type == 'deposit';
            final color = isDeposit
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            color: color.withValues(alpha: 0.12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(icon, size: 18, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.type[0].toUpperCase() + tx.type.substring(1),
                                style: DexTypography.bodyMedium.copyWith(
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
                        Text(
                          '\$${tx.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fade(delay: Duration(milliseconds: (300 + (i * 80)).toInt()))
                .slideX(begin: 0.05);
          }).toList(),
        );
      },
      loading: () => Column(
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerLoader(height: 64, borderRadius: 16),
          ),
        ),
      ),
      error: (_, __) => const Text('Failed to load activity'),
    );
  }

  Widget _buildMarketPulse(AsyncValue cryptosAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MARKET PULSE', style: DexTypography.label),
            GestureDetector(
              onTap: () => context.go('/trade'),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DexColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        cryptosAsync.when(
          data: (cryptos) => Column(
            children: cryptos.take(5).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value;
              return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          CryptoIcon(
                            symbol: c.symbol,
                            colorHex: c.iconColor,
                            size: 40,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: DexTypography.bodyMedium.copyWith(
                                    color: DexColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(c.symbol, style: DexTypography.caption),
                              ],
                            ),
                          ),
                          // Mini sparkline
                          SizedBox(
                            width: 60,
                            height: 28,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                      8,
                                      (j) => FlSpot(
                                        j.toDouble(),
                                        3 + Random(i * 8 + j).nextDouble() * 4,
                                      ),
                                    ),
                                    isCurved: true,
                                    color: c.isPositive
                                        ? DexColors.success
                                        : DexColors.error,
                                    barWidth: 1.5,
                                    dotData: const FlDotData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${c.price.toStringAsFixed(2)}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${c.isPositive ? '+' : ''}${c.change24h.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: c.isPositive
                                      ? DexColors.success
                                      : DexColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fade(delay: Duration(milliseconds: (350 + (i * 80)).toInt()))
                  .slideX(begin: 0.05);
            }).toList(),
          ),
          loading: () => Column(
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ShimmerLoader(height: 68, borderRadius: 16),
              ),
            ),
          ),
          error: (_, __) => const Text('Failed to load market data'),
        ),
      ],
    ).animate().fade(delay: 300.ms);
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

// ─── Quick Action Button ───

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, child) =>
              Transform.scale(scale: _scaleAnim.value, child: child),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 18),
            borderRadius: 18,
            borderColor: widget.color.withValues(alpha: 0.12),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: widget.color.withValues(alpha: 0.12),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(widget.icon, size: 20, color: widget.color),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: DexColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
