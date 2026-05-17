import 'package:flutter/material.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../widgets/glass_card.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Trade', style: DexTypography.h1),
          const SizedBox(height: 4),
          Text('Buy and sell digital assets', style: DexTypography.bodySmall),
          const SizedBox(height: 24),
          GlassCard(
            borderRadius: 22, padding: const EdgeInsets.all(28),
            child: Column(children: [
              Icon(Icons.candlestick_chart_rounded, size: 48, color: DexColors.primary.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text('Trading Terminal', style: DexTypography.h3),
              const SizedBox(height: 8),
              Text('Advanced trading interface coming in the next phase. Use the Transactions screen to simulate buy/sell operations.', style: DexTypography.bodySmall, textAlign: TextAlign.center),
            ]),
          ),
        ]),
      ),
    );
  }
}
