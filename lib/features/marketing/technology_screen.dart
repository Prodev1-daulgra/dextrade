import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glow_button.dart';
import 'design/dex_shader_illustration.dart';
import 'design/marketing_download_cta.dart';
import 'design/marketing_feature_panel.dart';
import 'design/marketing_page_scaffold.dart';
import 'marketing_shell.dart';

class TechnologyScreen extends StatelessWidget {
  const TechnologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MarketingPageScaffold(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TECHNOLOGY STACK',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: DexColors.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Engineered for\nsovereign flow.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Flutter terminal + Supabase rails + custom painters for brand art. No stock illustrations.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: DexColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const MarketingFeaturePanel(
          indexLabel: 'α',
          title: 'Realtime Rails',
          subtitle: 'Balances, transactions, and mirror positions stream live into the terminal.',
          bullets: [
            'Riverpod state graph',
            'Supabase realtime channels',
            'Optimistic UI with custom loaders',
          ],
          illustration: DexIllustrationKind.liquidityNexus,
        ),
        const MarketingFeaturePanel(
          indexLabel: 'β',
          title: 'Approval Mesh',
          subtitle: 'State-admin portal on web for deposits, withdrawals, and mirror approvals.',
          bullets: [
            'Role-gated routes',
            'Audit-friendly transaction timeline',
            'Custom push notification chrome',
          ],
          illustration: DexIllustrationKind.vaultLattice,
          flip: true,
        ),
        const MarketingFeaturePanel(
          indexLabel: 'γ',
          title: 'Dex Keypad',
          subtitle: 'Proprietary numpad for size entry — haptics, glow keys, confirm rail.',
          bullets: [
            'Trade & vault screens',
            'Decimal-aware entry',
            'Bottom-sheet native feel',
          ],
          illustration: DexIllustrationKind.matchEngine,
        ),
        const MarketingDownloadCta(),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: GlowButton(
              label: 'OPEN TERMINAL',
              onPressed: () => context.push('/login'),
              width: 260,
            ),
          ),
        ),
        const MarketingFooter(),
      ],
    );
  }
}
