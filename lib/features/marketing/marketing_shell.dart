import 'dart:ui' show ImageFilter;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../widgets/glow_button.dart';

/// Shared marketing website shell — premium glass navbar + fullscreen mobile menu + footer.
/// Wraps all public marketing pages (/landing, /features, /pricing, /about, /contact).
class MarketingShell extends StatefulWidget {
  final Widget child;
  const MarketingShell({super.key, required this.child});

  @override
  State<MarketingShell> createState() => _MarketingShellState();
}

class _MarketingShellState extends State<MarketingShell>
    with SingleTickerProviderStateMixin {
  bool _menuOpen = false;
  late final AnimationController _menuController;

  static const _navItems = [
    _NavItem('Home', '/landing', Icons.home_rounded),
    _NavItem('Features', '/features', Icons.auto_awesome_rounded),
    _NavItem('Pricing', '/pricing', Icons.diamond_rounded),
    _NavItem('About', '/about', Icons.info_outline_rounded),
    _NavItem('Contact', '/contact', Icons.mail_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
    if (_menuOpen) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  void _closeMenu() {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
      _menuController.reverse();
    }
  }

  String get _currentPath {
    final location = GoRouterState.of(context).matchedLocation;
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          widget.child,

          // Floating navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNavBar(context, isDesktop),
          ),

          // Fullscreen mobile menu overlay
          if (_menuOpen && !isDesktop) _buildFullscreenMenu(context),
        ],
      ),
    );
  }

  // ─── Premium Floating Glass Navigation Bar ───
  Widget _buildNavBar(BuildContext context, bool isDesktop) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 16,
          vertical: isDesktop ? 16 : 10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 18,
                vertical: isDesktop ? 16 : 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A12).withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: DexColors.primary.withOpacity(0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Logo
                  _buildLogo(context, isDesktop),
                  const Spacer(),

                  // Desktop nav links
                  if (isDesktop) ...[
                    for (final item in _navItems) _buildDesktopLink(item),
                    const SizedBox(width: 24),
                    // Auth buttons
                    _buildNavAuthButton(
                      'Log In',
                      onTap: () => context.push('/login'),
                      ghost: true,
                    ),
                    const SizedBox(width: 12),
                    GlowButton(
                      label: 'GET STARTED',
                      onPressed: () => context.push('/register'),
                      width: 140,
                    ),
                  ],

                  // Mobile hamburger
                  if (!isDesktop) ...[
                    _buildNavAuthButton(
                      'Login',
                      onTap: () => context.push('/login'),
                      ghost: true,
                      compact: true,
                    ),
                    const SizedBox(width: 8),
                    _buildHamburger(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        _closeMenu();
        context.go('/landing');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: DexColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DexColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.flash_on, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            'DEXTRADE',
            style: GoogleFonts.orbitron(
              fontSize: isDesktop ? 16 : 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLink(_NavItem item) {
    final isActive = _currentPath == item.path;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(item.path),
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              item.label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.8,
                color: isActive ? DexColors.primary : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavAuthButton(
    String label, {
    required VoidCallback onTap,
    bool ghost = false,
    bool compact = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 20,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: ghost
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
            color: ghost ? null : DexColors.primary.withOpacity(0.15),
          ),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: ghost ? Colors.white70 : DexColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHamburger() {
    return GestureDetector(
      onTap: _toggleMenu,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: AnimatedBuilder(
          animation: _menuController,
          builder: (context, _) {
            final t = _menuController.value;
            return CustomPaint(painter: _HamburgerPainter(t));
          },
        ),
      ),
    );
  }

  // ─── Fullscreen Overlay Mobile Menu ───
  Widget _buildFullscreenMenu(BuildContext context) {
    return AnimatedBuilder(
      animation: _menuController,
      builder: (context, _) {
        final t = _menuController.value;
        return Positioned.fill(
          child: GestureDetector(
            onTap: _closeMenu,
            child: Container(
              color: Colors.black.withOpacity(0.92 * t),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30 * t, sigmaY: 30 * t),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80), // below navbar
                        // Animated menu items
                        for (int i = 0; i < _navItems.length; i++)
                          _buildMobileMenuItem(_navItems[i], i, t),
                        const Spacer(),
                        // Bottom CTA
                        if (t > 0.5)
                          Opacity(
                            opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: GlowButton(
                                    label: 'CREATE ACCOUNT',
                                    onPressed: () {
                                      _closeMenu();
                                      context.push('/register');
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'INSTITUTIONAL LIQUIDITY PROTOCOL',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                    color: Colors.white24,
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuItem(_NavItem item, int index, double animValue) {
    final isActive = _currentPath == item.path;
    final delay = index * 0.08;
    final itemAnim = ((animValue - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    final curve = Curves.easeOutCubic.transform(itemAnim);

    return Transform.translate(
      offset: Offset(-30 * (1 - curve), 0),
      child: Opacity(
        opacity: curve,
        child: GestureDetector(
          onTap: () {
            _closeMenu();
            context.go(item.path);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isActive
                        ? DexColors.primary.withOpacity(0.12)
                        : Colors.white.withOpacity(0.03),
                    border: Border.all(
                      color: isActive
                          ? DexColors.primary.withOpacity(0.3)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    size: 18,
                    color: isActive ? DexColors.primary : Colors.white38,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  item.label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : Colors.white60,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DexColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: DexColors.primary.withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hamburger Custom Painter (animated X ↔ ☰) ───
class _HamburgerPainter extends CustomPainter {
  final double t;
  _HamburgerPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const halfW = 8.0;
    const gap = 5.0;

    // Top line → part of X
    final topY = cy - gap + (gap * t);
    final topAngle = t * math.pi / 4;
    canvas.save();
    canvas.translate(cx, topY);
    canvas.rotate(topAngle);
    canvas.drawLine(Offset(-halfW, 0), Offset(halfW, 0), paint);
    canvas.restore();

    // Middle line → fades out
    paint.color = Colors.white.withOpacity(0.8 * (1 - t));
    canvas.drawLine(Offset(cx - halfW, cy), Offset(cx + halfW, cy), paint);

    // Bottom line → part of X
    paint.color = Colors.white.withOpacity(0.8);
    final botY = cy + gap - (gap * t);
    final botAngle = -t * math.pi / 4;
    canvas.save();
    canvas.translate(cx, botY);
    canvas.rotate(botAngle);
    canvas.drawLine(Offset(-halfW, 0), Offset(halfW, 0), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HamburgerPainter old) => old.t != t;
}

// ─── Data model ───
class _NavItem {
  final String label;
  final String path;
  final IconData icon;
  const _NavItem(this.label, this.path, this.icon);
}

// ─── Shared Marketing Footer ───
class MarketingFooter extends StatelessWidget {
  const MarketingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF050508),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 24,
            vertical: 64,
          ),
          child: Column(
            children: [
              // Top section
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand column
                        Expanded(flex: 3, child: _buildBrandColumn()),
                        const SizedBox(width: 60),
                        // Links columns
                        Expanded(
                          flex: 2,
                          child: _buildLinksColumn(context, 'Product', [
                            'Features',
                            'Pricing',
                            'Copy Trading',
                            'API Access',
                          ]),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildLinksColumn(context, 'Company', [
                            'About',
                            'Contact',
                            'Careers',
                            'Press Kit',
                          ]),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildLinksColumn(context, 'Legal', [
                            'Privacy Policy',
                            'Terms of Service',
                            'Cookie Policy',
                            'Compliance',
                          ]),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandColumn(),
                        const SizedBox(height: 40),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildLinksColumn(context, 'Product', [
                                'Features',
                                'Pricing',
                                'Copy Trading',
                              ]),
                            ),
                            Expanded(
                              child: _buildLinksColumn(context, 'Company', [
                                'About',
                                'Contact',
                                'Careers',
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: 48),
              // Divider
              Container(height: 1, color: Colors.white.withOpacity(0.06)),
              const SizedBox(height: 24),
              // Bottom row
              isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '© 2026 Dextrade. All rights reserved.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white24,
                          ),
                        ),
                        Row(
                          children: [
                            _buildSocialIcon(Icons.language),
                            const SizedBox(width: 12),
                            _buildSocialIcon(Icons.alternate_email),
                            const SizedBox(width: 12),
                            _buildSocialIcon(Icons.code_rounded),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialIcon(Icons.language),
                            const SizedBox(width: 12),
                            _buildSocialIcon(Icons.alternate_email),
                            const SizedBox(width: 12),
                            _buildSocialIcon(Icons.code_rounded),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '© 2026 Dextrade. All rights reserved.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: DexColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Text(
              'DEXTRADE',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Institutional-grade liquidity protocol. Direct matching engine access for sovereign performance.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: Colors.white38,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _buildDownloadButton(
              icon: Icons.android_rounded,
              label: 'Download APK',
              onTap: () {
                // Future: launchUrl(Uri.parse('https://dextrade.com/app-release.apk'));
              },
            ),
            const SizedBox(width: 12),
            _buildDownloadButton(
              icon: Icons.apple_rounded,
              label: 'iOS (Coming Soon)',
              disabled: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: disabled ? Colors.white.withOpacity(0.02) : DexColors.primary.withOpacity(0.1),
            border: Border.all(
              color: disabled ? Colors.white.withOpacity(0.05) : DexColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: disabled ? Colors.white30 : DexColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: disabled ? Colors.white30 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinksColumn(
    BuildContext context,
    String title,
    List<String> links,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 16),
        for (final link in links) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                link,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.white30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Icon(icon, color: Colors.white30, size: 16),
    );
  }
}
