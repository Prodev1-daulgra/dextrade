import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/dex_colors.dart';
import 'core/theme/dex_typography.dart';
import 'providers/providers.dart';
import 'widgets/pulse_dot.dart';
import 'widgets/dex_app_background.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  static const _mobileNavItems = [
    _NavItem('/', Icons.dashboard_rounded, 'Home'),
    _NavItem('/portfolio', Icons.pie_chart_rounded, 'Portfolio'),
    _NavItem('/trade', Icons.candlestick_chart_rounded, 'Trade'),
    _NavItem('/copy-trading', Icons.people_rounded, 'Mirror'),
    _NavItem('/transactions', Icons.receipt_long_rounded, 'Vault'),
    _NavItem('/settings', Icons.tune_rounded, 'Settings'),
  ];

  static const _webNavItems = [
    _NavItem('/', Icons.dashboard_rounded, 'Dashboard'),
    _NavItem('/portfolio', Icons.pie_chart_rounded, 'Portfolio'),
    _NavItem('/trade', Icons.candlestick_chart_rounded, 'Trade'),
    _NavItem('/copy-trading', Icons.people_rounded, 'Copy Trading'),
    _NavItem('/transactions', Icons.receipt_long_rounded, 'Transactions'),
    _NavItem('/state-admin', Icons.tune_rounded, 'State Admin'),
    _NavItem('/settings', Icons.settings_rounded, 'Settings'),
  ];

  List<_NavItem> _navItemsFor(AuthState auth) {
    if (!kIsWeb) return _mobileNavItems;
    final items = List<_NavItem>.from(_webNavItems);
    if (auth.isSuperAdmin) {
      items.add(
        const _NavItem(
          '/superadmin',
          Icons.admin_panel_settings_rounded,
          'Super Admin',
        ),
      );
    }
    return items;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final auth = ref.read(authProvider);
    final items = _navItemsFor(auth);
    final idx = items.indexWhere((e) => e.path == location);
    if (idx >= 0 && idx != _currentIndex) {
      setState(() => _currentIndex = idx);
    }
  }

  void _onNavTap(int index, AuthState auth) {
    final items = _navItemsFor(auth);
    if (index < items.length) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
      context.go(items[index].path);
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/landing');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final auth = ref.watch(authProvider);

    if (isWide && kIsWeb) {
      return _buildWebLayout(auth);
    }
    return _buildMobileLayout(auth);
  }

  Widget _buildMobileLayout(AuthState auth) {
    return Scaffold(
      body: DexAppBackground(child: widget.child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D18),
          border: const Border(
            top: BorderSide(color: DexColors.border, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_mobileNavItems.length, (i) {
                final item = _mobileNavItems[i];
                final isActive = _currentIndex == i;
                return _MobileNavButton(
                  icon: item.icon,
                  label: item.label,
                  isActive: isActive,
                  onTap: () => _onNavTap(i, auth),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(AuthState auth) {
    final navItems = _navItemsFor(auth);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D18),
              border: const Border(
                right: BorderSide(color: DexColors.border, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: DexColors.primaryGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DexColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'D',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'DEXTRADE',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: DexColors.success.withValues(alpha: 0.06),
                      border: Border.all(
                        color: DexColors.success.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const PulseDot(color: DexColors.success, size: 6),
                        const SizedBox(width: 8),
                        Text(
                          'SYSTEM ONLINE',
                          style: GoogleFonts.orbitron(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: DexColors.success,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: navItems.length,
                    itemBuilder: (context, i) {
                      final item = navItems[i];
                      final isActive = _currentIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: _WebNavButton(
                          icon: item.icon,
                          label: item.label,
                          isActive: isActive,
                          onTap: () => _onNavTap(i, auth),
                        ),
                      );
                    },
                  ),
                ),
                // User info + logout
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: DexColors.surfaceLight,
                    border: Border.all(color: DexColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              DexColors.primary.withValues(alpha: 0.3),
                              DexColors.primary.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            (auth.user?.fullName ?? auth.user?.email ?? 'U')[0]
                                .toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              color: DexColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.user?.fullName ?? 'User',
                              style: DexTypography.bodySmall.copyWith(
                                color: DexColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              auth.user?.email ?? '',
                              style: DexTypography.caption.copyWith(
                                fontSize: 9,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: DexColors.textMuted,
                        ),
                        onPressed: _logout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: DexAppBackground(child: widget.child),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String label;
  const _NavItem(this.path, this.icon, this.label);
}

// ─── Premium Mobile Nav Button ───

class _MobileNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_MobileNavButton> createState() => _MobileNavButtonState();
}

class _MobileNavButtonState extends State<_MobileNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
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
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.isActive
                ? DexColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: widget.isActive ? 16 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: widget.isActive
                      ? DexColors.primary
                      : Colors.transparent,
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: DexColors.primary.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ]
                      : [],
                ),
              ),
              Icon(
                widget.icon,
                size: 22,
                color: widget.isActive
                    ? DexColors.primary
                    : DexColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: widget.isActive
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: widget.isActive
                      ? DexColors.primary
                      : DexColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Web Nav Button ───

class _WebNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _WebNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_WebNavButton> createState() => _WebNavButtonState();
}

class _WebNavButtonState extends State<_WebNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActiveOrHovered = widget.isActive || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isActive
                ? DexColors.primary.withValues(alpha: 0.1)
                : _isHovered
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.transparent,
            border: widget.isActive
                ? Border.all(color: DexColors.primary.withValues(alpha: 0.2))
                : null,
          ),
          child: Row(
            children: [
              // Active indicator bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: widget.isActive ? 20 : 0,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: widget.isActive
                      ? DexColors.primary
                      : Colors.transparent,
                ),
              ),
              Icon(
                widget.icon,
                size: 20,
                color: isActiveOrHovered
                    ? DexColors.primary
                    : DexColors.textMuted,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isActiveOrHovered
                      ? Colors.white
                      : DexColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
