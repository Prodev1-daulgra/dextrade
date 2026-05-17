import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/dex_colors.dart';
import 'core/theme/dex_typography.dart';
import 'providers/providers.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final items = kIsWeb ? _webNavItems : _mobileNavItems;
    final idx = items.indexWhere((e) => e.path == location);
    if (idx >= 0 && idx != _currentIndex) {
      setState(() => _currentIndex = idx);
    }
  }

  void _onNavTap(int index) {
    final items = kIsWeb ? _webNavItems : _mobileNavItems;
    if (index < items.length) {
      setState(() => _currentIndex = index);
      context.go(items[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final auth = ref.watch(authProvider);

    if (isWide && kIsWeb) {
      return _buildWebLayout(auth);
    }
    return _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: DexColors.surface,
          border: Border(top: BorderSide(color: DexColors.border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_mobileNavItems.length, (i) {
                final item = _mobileNavItems[i];
                final isActive = _currentIndex == i;
                return _MobileNavButton(
                  icon: item.icon,
                  label: item.label,
                  isActive: isActive,
                  onTap: () => _onNavTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(AuthState auth) {
    var navItems = List<_NavItem>.from(_webNavItems);
    // Add superadmin link for the superadmin
    if (auth.isSuperAdmin) {
      navItems.add(const _NavItem('/superadmin', Icons.admin_panel_settings_rounded, 'Super Admin'));
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: DexColors.surface,
              border: Border(right: BorderSide(color: DexColors.border, width: 1)),
            ),
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(colors: DexColors.primaryGradient),
                        ),
                        child: const Center(
                          child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('DEXTRADE', style: DexTypography.h3.copyWith(letterSpacing: 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: navItems.length,
                    itemBuilder: (context, i) {
                      final item = navItems[i];
                      final isActive = _currentIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _WebNavButton(
                          icon: item.icon,
                          label: item.label,
                          isActive: isActive,
                          onTap: () => _onNavTap(i),
                        ),
                      );
                    },
                  ),
                ),
                // User info + logout
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: DexColors.surfaceLight,
                    border: Border.all(color: DexColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: DexColors.primary.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Text(
                            (auth.user?.fullName ?? auth.user?.email ?? 'U')[0].toUpperCase(),
                            style: TextStyle(color: DexColors.primary, fontWeight: FontWeight.w800, fontSize: 14),
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
                              style: DexTypography.bodySmall.copyWith(color: DexColors.textPrimary, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              auth.user?.email ?? '',
                              style: DexTypography.caption.copyWith(fontSize: 9),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, size: 18, color: DexColors.textMuted),
                        onPressed: () => ref.read(authProvider.notifier).logout(),
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
            child: Container(
              color: DexColors.background,
              child: widget.child,
            ),
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

class _MobileNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileNavButton({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? DexColors.primary.withValues(alpha: 0.12) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? DexColors.primary : DexColors.textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive ? DexColors.primary : DexColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _WebNavButton({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive ? DexColors.primary.withValues(alpha: 0.1) : Colors.transparent,
            border: isActive ? Border.all(color: DexColors.primary.withValues(alpha: 0.2)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isActive ? DexColors.primary : DexColors.textMuted),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? DexColors.primary : DexColors.textSecondary,
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
