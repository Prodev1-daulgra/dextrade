import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/hud/hud_screen_header.dart';
import '../../widgets/hud/hud_segmented_control.dart';
import '../../widgets/hud/hud_panel.dart';
import '../../widgets/hud/hud_timeframe_chips.dart';
import '../../widgets/hud/notification_inbox_sheet.dart';
import '../../widgets/dex_shockwave_loader.dart';
import '../../core/utils/dex_feedback.dart';
import '../../data/models/copy_trade_model.dart';

class CopyTradingScreen extends ConsumerStatefulWidget {
  const CopyTradingScreen({super.key});

  @override
  ConsumerState<CopyTradingScreen> createState() => _CopyTradingScreenState();
}

class _CopyTradingScreenState extends ConsumerState<CopyTradingScreen> {
  final Map<String, List<double>> _sparklineCache = {};
  String _riskFilter = 'all';
  String _sortMode = 'roi';
  final Set<String> _pinnedTraders = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMirrorPrefs());
  }

  Future<void> _loadMirrorPrefs() async {
    final email = ref.read(authProvider).email;
    if (email == null) return;
    final prefs = await ref.read(microFeaturesRepoProvider).getPreferences(email);
    if (mounted) {
      setState(() => _sortMode = prefs.mirrorSort);
    }
  }

  // Generate a consistent pseudo-random sparkline curve based on the trader ID
  List<double> _getSparklinePoints(String traderId, double profitPct) {
    if (_sparklineCache.containsKey(traderId)) {
      return _sparklineCache[traderId]!;
    }

    final math.Random rand = math.Random(traderId.hashCode);
    final List<double> points = [0.0];
    double currentVal = 0.0;
    int steps = 14;

    for (int i = 0; i < steps; i++) {
      // General drift upward to match profitPct
      final double trend = profitPct / steps;
      final double noise = (rand.nextDouble() - 0.4) * (profitPct * 0.15);
      currentVal += trend + noise;
      points.add(currentVal);
    }
    _sparklineCache[traderId] = points;
    return points;
  }

  // Opens a beautiful allocation bottom sheet to simulate capital allocation
  void _openAllocationDialog(
    BuildContext context,
    WidgetRef ref,
    String email,
    CopyTraderModel trader,
  ) {
    final TextEditingController allocCtrl = TextEditingController(
      text: trader.minAllocation.toStringAsFixed(0),
    );
    double sliderVal = trader.minAllocation;
    bool processing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF06060C),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DexColors.primary.withOpacity(0.12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.flash_on_rounded,
                              color: DexColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mirror Configuration',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Allocating to ${trader.traderName}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                color: DexColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'TARGET ALLOCATION BALANCE (USDT)',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Colors.white30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: TextField(
                        controller: allocCtrl,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: "USDT",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final double? numVal = double.tryParse(val);
                          if (numVal != null) {
                            setModalState(() {
                              sliderVal = numVal.clamp(
                                trader.minAllocation,
                                10000.0,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: DexColors.primary,
                        inactiveTrackColor: Colors.white.withOpacity(0.08),
                        thumbColor: Colors.white,
                        overlayColor: DexColors.primary.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: sliderVal.clamp(trader.minAllocation, 10000.0),
                        min: trader.minAllocation,
                        max: 10000.0,
                        divisions: 99,
                        onChanged: (val) {
                          setModalState(() {
                            sliderVal = val;
                            allocCtrl.text = val.toStringAsFixed(0);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minimum Required: \$${trader.minAllocation.toStringAsFixed(0)}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white30,
                          ),
                        ),
                        Text(
                          'Platform Cap: \$10,000',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    GlowButton(
                      label: 'Deploy Mirror Tunnel',
                      onPressed: processing
                          ? null
                          : () async {
                              final double amt =
                                  double.tryParse(allocCtrl.text) ?? 0.0;
                              if (amt < trader.minAllocation) {
                                DexToast.showPushNotification(
                                  context,
                                  title: 'Error',
                                  body:
                                      'Allocation is below the trader\'s minimum limit.',
                                );
                                return;
                              }

                              setModalState(() => processing = true);
                              try {
                                await ref
                                    .read(copyTradeRepoProvider)
                                    .initializeMirror(email, trader);
                                ref.invalidate(userCopyTradesProvider(email));
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  await DexFeedback.notify(
                                    ref,
                                    context,
                                    title: 'Mirror active',
                                    body: 'Capital allocated to ${trader.traderName}',
                                    kind: 'mirror',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setModalState(() => processing = false);
                                  DexToast.showPushNotification(
                                    context,
                                    title: 'Error',
                                    body: e.toString(),
                                  );
                                }
                              }
                            },
                      isLoading: processing,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final email = auth.email ?? '';
    final tradersAsync = ref.watch(copyTradersProvider);
    final copiesAsync = ref.watch(userCopyTradesProvider(email));

    final riskColors = {
      'low': DexColors.success,
      'medium': DexColors.warning,
      'high': DexColors.error,
    };
    final unread = ref.watch(unreadNotificationsCountProvider(email));

    return SafeArea(
      child: RefreshIndicator(
        color: DexColors.primary,
        onRefresh: () async {
          ref.invalidate(copyTradersProvider);
          ref.invalidate(userCopyTradesProvider(email));
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HudScreenHeader(
                title: 'Mirror Desk',
                subtitle: 'Copy elite nodes · ROI rails · risk caps',
                trailing: [
                  IconButton(
                    onPressed: () => NotificationInboxSheet.show(context),
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: DexColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              HudSegmentedControl(
                labels: const ['All risk', 'Low', 'Med', 'High'],
                selectedIndex: ['all', 'low', 'medium', 'high'].indexOf(_riskFilter),
                onChanged: (i) {
                  setState(() {
                    _riskFilter = ['all', 'low', 'medium', 'high'][i];
                  });
                  ref.read(microFeaturesRepoProvider).upsertPreferences(
                        mirrorSort: _sortMode,
                      );
                },
              ),
              const SizedBox(height: 10),
              HudTimeframeChips(
                timeframes: const ['ROI', 'Win %', 'Followers'],
                selected: _sortMode == 'roi'
                    ? 'ROI'
                    : _sortMode == 'win_rate'
                        ? 'Win %'
                        : 'Followers',
                onSelected: (v) {
                  setState(() {
                    _sortMode = v == 'ROI'
                        ? 'roi'
                        : v == 'Win %'
                            ? 'win_rate'
                            : 'followers';
                  });
                  ref.read(microFeaturesRepoProvider).upsertPreferences(
                        mirrorSort: _sortMode,
                      );
                },
                accent: DexColors.primary,
              ),
              const SizedBox(height: 24),

            tradersAsync.when(
              data: (traders) {
                if (traders.isEmpty) {
                  return HudPanel(
                    title: 'No nodes',
                    subtitle: 'Seed copy_traders in Supabase',
                    child: Column(
                      children: [
                        const DexShockwaveLoader(size: 80, brandLabel: 'Mirror'),
                        const SizedBox(height: 16),
                        Text(
                          'No active matching nodes in cluster.',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white30,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var list = traders.where((t) {
                  if (_riskFilter == 'all') return true;
                  return t.riskLevel == _riskFilter;
                }).toList();

                list.sort((a, b) {
                  switch (_sortMode) {
                    case 'win_rate':
                      return b.winRate.compareTo(a.winRate);
                    case 'followers':
                      return b.followers.compareTo(a.followers);
                    default:
                      return b.totalProfitPct.compareTo(a.totalProfitPct);
                  }
                });

                final pinned = list.where((t) => _pinnedTraders.contains(t.id)).toList();
                final rest = list.where((t) => !_pinnedTraders.contains(t.id)).toList();
                list = [...pinned, ...rest];

                return Column(
                  children: List.generate(list.length, (idx) {
                    final trader = list[idx];
                    final activeCopies = copiesAsync.valueOrNull ?? [];
                    final activeCopy = activeCopies
                        .where((c) => c.traderId == trader.id)
                        .firstOrNull;
                    final riskColor =
                        riskColors[trader.riskLevel] ?? DexColors.warning;
                    final bool isSynced = activeCopy != null;

                    return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: isSynced
                                  ? [
                                      BoxShadow(
                                        color: DexColors.primary.withOpacity(
                                          0.12,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: GlassCard(
                              padding: const EdgeInsets.all(28),
                              borderRadius: 28,
                              borderColor: isSynced
                                  ? DexColors.primary.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          color: Color(
                                            int.parse(
                                              trader.avatarColor.replaceFirst(
                                                '#',
                                                '0xFF',
                                              ),
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(
                                                int.parse(
                                                  trader.avatarColor
                                                      .replaceFirst(
                                                        '#',
                                                        '0xFF',
                                                      ),
                                                ),
                                              ).withOpacity(0.2),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            trader.traderName
                                                .substring(0, 2)
                                                .toUpperCase(),
                                            style: GoogleFonts.orbitron(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              trader.traderName,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    color: DexColors.primary
                                                        .withOpacity(0.08),
                                                  ),
                                                  child: Text(
                                                    trader.specialty ??
                                                        'Institutional',
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: DexColors
                                                              .primaryGlow,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    color: riskColor
                                                        .withOpacity(0.08),
                                                  ),
                                                  child: Text(
                                                    trader.riskLevel
                                                        .toUpperCase(),
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: riskColor,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          DexFeedback.haptic(ref);
                                          setState(() {
                                            if (_pinnedTraders.contains(trader.id)) {
                                              _pinnedTraders.remove(trader.id);
                                            } else {
                                              _pinnedTraders.add(trader.id);
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          _pinnedTraders.contains(trader.id)
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: _pinnedTraders.contains(trader.id)
                                              ? DexColors.warning
                                              : DexColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Interactive Stats Layout + Neon Sparkline graph
                                  Row(
                                    children: [
                                      _StatCol(
                                        'Return',
                                        '+${trader.totalProfitPct.toStringAsFixed(1)}%',
                                        DexColors.success,
                                      ),
                                      _StatCol(
                                        'Win Rate',
                                        '${trader.winRate.toStringAsFixed(0)}%',
                                        Colors.white,
                                      ),
                                      _StatCol(
                                        'Followers',
                                        '${trader.followers}',
                                        Colors.white,
                                      ),
                                      _StatCol(
                                        'Min Required',
                                        '\$${trader.minAllocation.toStringAsFixed(0)}',
                                        DexColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Floating neon sparkline cumulative profit visual curve
                                  Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.005),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CustomPaint(
                                      size: Size.infinite,
                                      painter: _SparklinePainter(
                                        points: _getSparklinePoints(
                                          trader.id,
                                          trader.totalProfitPct,
                                        ),
                                        lineColor: isSynced
                                            ? DexColors.primary
                                            : DexColors.success,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  if (isSynced)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: DexColors.primary.withOpacity(
                                          0.06,
                                        ),
                                        border: Border.all(
                                          color: DexColors.primary.withOpacity(
                                            0.2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Pulsating green sync node
                                          const _PulsatingNode(
                                            color: DexColors.success,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'SYNCED TERMINAL ACTIVE',
                                            style: GoogleFonts.orbitron(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white70,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${activeCopy.profitLoss >= 0 ? '+' : ''}\$${activeCopy.profitLoss.toStringAsFixed(2)} P&L',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: activeCopy.profitLoss >= 0
                                                  ? DexColors.successGlow
                                                  : DexColors.errorGlow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    GlowButton(
                                      label: 'Initialize Mirror Sync',
                                      icon: Icons.flash_on_rounded,
                                      width: double.infinity,
                                      onPressed: () => _openAllocationDialog(
                                        context,
                                        ref,
                                        email,
                                        trader,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 500.ms, delay: (idx * 100).ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
                  }),
                );
              },
              loading: () => Column(
                children: List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ShimmerLoader(height: 220, borderRadius: 28),
                  ),
                ),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Failed to locate alignment traders.',
                  style: GoogleFonts.spaceGrotesk(
                    color: DexColors.error,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.white30,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulsating active mirrored node indicator ───
class _PulsatingNode extends StatefulWidget {
  final Color color;
  const _PulsatingNode({required this.color});

  @override
  State<_PulsatingNode> createState() => _PulsatingNodeState();
}

class _PulsatingNodeState extends State<_PulsatingNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 8 + (_controller.value * 12),
              height: 8 + (_controller.value * 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(1.0 - _controller.value),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Custom painted neon sparkline yield curve graph ───
class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  _SparklinePainter({required this.points, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    double maxVal = points.reduce(math.max);
    double minVal = points.reduce(math.min);
    if (maxVal == minVal) {
      maxVal += 1.0;
      minVal -= 1.0;
    }

    final double stepX = width / (points.length - 1);
    final Path path = Path();
    final Path fillPath = Path();

    // Map points coordinates
    double getX(int idx) => idx * stepX;
    double getY(double val) =>
        height - ((val - minVal) / (maxVal - minVal)) * (height - 8) - 4;

    path.moveTo(getX(0), getY(points.first));
    fillPath.moveTo(getX(0), height);
    fillPath.lineTo(getX(0), getY(points.first));

    for (int i = 1; i < points.length; i++) {
      final double prevX = getX(i - 1);
      final double prevY = getY(points[i - 1]);
      final double currX = getX(i);
      final double currY = getY(points[i]);

      // Draw smooth Bezier curve connections
      final double ctrlX1 = prevX + stepX * 0.5;
      final double ctrlY1 = prevY;
      final double ctrlX2 = prevX + stepX * 0.5;
      final double ctrlY2 = currY;

      path.cubicTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, currX, currY);
      fillPath.cubicTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, currX, currY);
    }

    fillPath.lineTo(getX(points.length - 1), height);
    fillPath.close();

    // Paint solid neon line
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.8);
    canvas.drawPath(path, linePaint);

    // Paint neon background glow aura
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = lineColor.withOpacity(0.2)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    // Paint soft area fill gradient underneath the line
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.08), lineColor.withOpacity(0.00)],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
