import 'package:flutter/material.dart';
import '../core/theme/dex_colors.dart';
import '../core/theme/dex_typography.dart';

class TickerItem {
  final String symbol;
  final String price;
  final String change;
  final bool isPositive;

  const TickerItem({
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
  });
}

const _kDefaultTickers = [
  TickerItem(symbol: 'BTC', price: '97,240', change: '+2.4%', isPositive: true),
  TickerItem(symbol: 'ETH', price: '3,842', change: '+1.8%', isPositive: true),
  TickerItem(symbol: 'SOL', price: '198.12', change: '+5.2%', isPositive: true),
  TickerItem(symbol: 'AAPL', price: '224.50', change: '+1.2%', isPositive: true),
  TickerItem(symbol: 'NVDA', price: '145.82', change: '+3.1%', isPositive: true),
  TickerItem(symbol: 'TSLA', price: '342.10', change: '-0.8%', isPositive: false),
];

class TickerTape extends StatefulWidget {
  final List<TickerItem> items;
  final double speed; // Pixels per second

  const TickerTape({
    super.key,
    this.items = _kDefaultTickers,
    this.speed = 50.0,
  });

  @override
  State<TickerTape> createState() => _TickerTapeState();
}

class _TickerTapeState extends State<TickerTape> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We render the list 3 times to create an infinite scroll illusion
    final repeatedItems = [...widget.items, ...widget.items, ...widget.items];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: DexColors.surfaceGlass,
        border: const Border.symmetric(
          horizontal: BorderSide(color: DexColors.borderLight),
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-_controller.value * 1500, 0),
                child: Row(
                  children: repeatedItems.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 64),
                    child: _buildTicker(t),
                  )).toList(),
                ),
              );
            },
          ),
          // Left Fade
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [DexColors.background, DexColors.background.withValues(alpha: 0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          // Right Fade
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [DexColors.background.withValues(alpha: 0), DexColors.background],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicker(TickerItem t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(t.symbol, style: DexTypography.label.copyWith(color: DexColors.textSecondary)),
        const SizedBox(width: 16),
        Text('\$${t.price}', style: DexTypography.mono.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: t.isPositive ? DexColors.successGlow : DexColors.errorGlow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: t.isPositive ? DexColors.success.withValues(alpha: 0.2) : DexColors.error.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            t.change,
            style: DexTypography.label.copyWith(
              color: t.isPositive ? DexColors.success : DexColors.error,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
