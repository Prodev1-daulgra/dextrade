import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import 'design/marketing_download_cta.dart';
import 'design/marketing_page_scaffold.dart';
import 'marketing_shell.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return MarketingPageScaffold(
      showFooter: false,
      children: [
        _buildHero(isDesktop),
        _buildContactFormAndInfo(isDesktop),
        _buildGlobalOffices(isDesktop),
        const MarketingDownloadCta(),
        const MarketingFooter(),
      ],
    );
  }

  Widget _buildHero(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: isDesktop ? 64 : 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Text(
                'GET IN TOUCH',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.primaryGlow,
                ),
              ).animate().fade().slideY(begin: 0.1),
              const SizedBox(height: 16),
              Text(
                'We\'re Here to Help',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 80 : 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.05,
                  letterSpacing: -3,
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              Text(
                'Whether you have a question about features, pricing, or need technical support, our team is ready to answer all your questions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: DexColors.textSecondary,
                ),
              ).animate().fade(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactFormAndInfo(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 32,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildContactForm()),
                    const SizedBox(width: 64),
                    Expanded(flex: 4, child: _buildContactInfo()),
                  ],
                )
              : Column(
                  children: [
                    _buildContactInfo(),
                    const SizedBox(height: 48),
                    _buildContactForm(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send us a message',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField('First Name', 'John')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Last Name', 'Doe')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Email Address', 'john@example.com'),
          const SizedBox(height: 16),
          _buildTextField('Subject', 'How can we help?'),
          const SizedBox(height: 16),
          _buildTextField(
            'Message',
            'Tell us more about your inquiry...',
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          GlowButton(
            label: 'SEND MESSAGE',
            onPressed: () {},
            width: double.infinity,
          ),
        ],
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white24,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DexColors.primary.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    final items = [
      (
        Icons.discord,
        'Discord Community',
        'Join 50K+ traders and core devs.',
        'discord.gg/dextrade',
        DexColors.primary,
      ),
      (
        Icons.telegram,
        'Telegram Alpha',
        'Real-time updates and market signals.',
        't.me/dextrade',
        DexColors.accent,
      ),
      (
        Icons.flutter_dash, // X icon placeholder
        'X (Twitter)',
        'Latest announcements and features.',
        '@dextrade',
        Colors.white,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 20,
            borderColor: item.$5.withOpacity(0.1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.$5.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.$5.withOpacity(0.2)),
                  ),
                  child: Icon(item.$1, color: item.$5, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.$3,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: DexColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            item.$4,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.$5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: item.$5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fade(delay: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildGlobalOffices(bool isDesktop) {
    final offices = [
      (
        'New York',
        'Headquarters',
        '100 Wall Street\nSuite 1200\nNew York, NY 10005',
        '🇺🇸',
      ),
      (
        'London',
        'European Engineering',
        '1 Canada Square\nCanary Wharf\nLondon E14 5AB',
        '🇬🇧',
      ),
      (
        'Singapore',
        'APAC Operations',
        '10 Bayfront Avenue\nMarina Bay Sands\nSingapore 018956',
        '🇸🇬',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GLOBAL PRESENCE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: DexColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Our Offices',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              isDesktop
                  ? Row(
                      children: offices
                          .asMap()
                          .entries
                          .map(
                            (e) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: _buildOfficeCard(e.value)
                                    .animate()
                                    .fade(
                                      delay: Duration(
                                        milliseconds: 200 + e.key * 100,
                                      ),
                                    )
                                    .slideY(begin: 0.05),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Column(
                      children: offices
                          .asMap()
                          .entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildOfficeCard(e.value)
                                  .animate()
                                  .fade(
                                    delay: Duration(
                                      milliseconds: 200 + e.key * 100,
                                    ),
                                  )
                                  .slideY(begin: 0.05),
                            ),
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficeCard((String, String, String, String) office) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 20,
      borderColor: Colors.white.withOpacity(0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                office.$1,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(office.$4, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            office.$2,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DexColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            office.$3,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: DexColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
