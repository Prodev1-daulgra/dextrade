import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';

/// Depth-of-market style horizontal bars (asks red-tint, bids green-tint).
class HudDepthLadder extends StatelessWidget {
  final List<Map<String, dynamic>> asks;
  final List<Map<String, dynamic>> bids;
  final double maxSize;

  const HudDepthLadder({
    super.key,
    required this.asks,
    required this.bids,
    required this.maxSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...asks.take(6).map((r) => _DepthRow(
              price: r['price'] as double,
              size: r['size'] as double,
              maxSize: maxSize,
              isAsk: true,
              flash: r['flash'] == true,
            )),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: DexColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'SPREAD',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: DexColors.primary,
              letterSpacing: 2,
            ),
          ),
        ),
        ...bids.take(6).map((r) => _DepthRow(
              price: r['price'] as double,
              size: r['size'] as double,
              maxSize: maxSize,
              isAsk: false,
              flash: r['flash'] == true,
            )),
      ],
    );
  }
}

class _DepthRow extends StatelessWidget {
  final double price;
  final double size;
  final double maxSize;
  final bool isAsk;
  final bool flash;

  const _DepthRow({
    required this.price,
    required this.size,
    required this.maxSize,
    required this.isAsk,
    required this.flash,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAsk ? DexColors.error : DexColors.success;
    final pct = (size / maxSize).clamp(0.05, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          Align(
            alignment: isAsk ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 22,
              child: FractionallySizedBox(
                widthFactor: pct,
                alignment: isAsk ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: color.withValues(alpha: flash ? 0.35 : 0.12),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price.toStringAsFixed(2),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  size.toStringAsFixed(3),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: DexColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
