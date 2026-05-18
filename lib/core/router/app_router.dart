import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/landing/landing_screen.dart';
import '../../features/marketing/marketing_shell.dart';
import '../../features/marketing/features_screen.dart';
import '../../features/marketing/pricing_screen.dart';
import '../../features/marketing/about_screen.dart';
import '../../features/marketing/contact_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/copy_trading/copy_trading_screen.dart';
import '../../features/portfolio/portfolio_screen.dart';
import '../../features/trade/trade_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/state_admin/state_admin_screen.dart';
import '../../features/superadmin/superadmin_screen.dart';
import '../../app_shell.dart';
import '../../widgets/dex_page_transition.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final path = state.matchedLocation;

      if (isLoading) return null;

      final publicPaths = [
        '/login',
        '/register',
        '/landing',
        '/features',
        '/pricing',
        '/about',
        '/contact',
      ];
      final isPublicPath = publicPaths.contains(path);

      if (!isAuth && !isPublicPath) return '/landing';
      if (isAuth && isPublicPath) return '/';

      // State admin: web-only guard
      if (path.startsWith('/state-admin') && !kIsWeb) return '/';

      // Superadmin guard
      if (path.startsWith('/superadmin') && !authState.isSuperAdmin) return '/';

      return null;
    },
    routes: [
      // Auth routes (no shell — cinematic transitions)
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => DexPageTransition(child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, __) =>
            DexPageTransition(child: const RegisterScreen()),
      ),

      // Marketing Shell (wraps landing and all marketing pages)
      ShellRoute(
        builder: (context, state, child) => MarketingShell(child: child),
        routes: [
          GoRoute(
            path: '/landing',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const LandingScreen()),
          ),
          GoRoute(
            path: '/features',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const FeaturesScreen()),
          ),
          GoRoute(
            path: '/pricing',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const PricingScreen()),
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const AboutScreen()),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const ContactScreen()),
          ),
        ],
      ),

      // App shell with navigation — all child routes use cinematic transitions
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const DashboardScreen()),
          ),
          GoRoute(
            path: '/portfolio',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const PortfolioScreen()),
          ),
          GoRoute(
            path: '/trade',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const TradeScreen()),
          ),
          GoRoute(
            path: '/copy-trading',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const CopyTradingScreen()),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const TransactionsScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, __) =>
                DexPageTransition(child: const SettingsScreen()),
          ),
          // Web-only routes
          if (kIsWeb) ...[
            GoRoute(
              path: '/state-admin',
              pageBuilder: (_, __) =>
                  DexPageTransition(child: const StateAdminScreen()),
            ),
            GoRoute(
              path: '/superadmin',
              pageBuilder: (_, __) =>
                  DexPageTransition(child: const SuperadminScreen()),
            ),
          ],
        ],
      ),
    ],
  );
});
