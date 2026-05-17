import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/copy_trading/copy_trading_screen.dart';
import '../../features/portfolio/portfolio_screen.dart';
import '../../features/trade/trade_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/state_admin/state_admin_screen.dart';
import '../../features/superadmin/superadmin_screen.dart';
import '../../app_shell.dart';

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

      final authPaths = ['/login', '/register'];
      final isAuthPath = authPaths.contains(path);

      if (!isAuth && !isAuthPath) return '/login';
      if (isAuth && isAuthPath) return '/';

      // State admin: web-only guard
      if (path.startsWith('/state-admin') && !kIsWeb) return '/';

      // Superadmin guard
      if (path.startsWith('/superadmin') && !authState.isSuperAdmin) return '/';

      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // App shell with navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/portfolio', builder: (_, __) => const PortfolioScreen()),
          GoRoute(path: '/trade', builder: (_, __) => const TradeScreen()),
          GoRoute(path: '/copy-trading', builder: (_, __) => const CopyTradingScreen()),
          GoRoute(path: '/transactions', builder: (_, __) => const TransactionsScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          // Web-only routes
          if (kIsWeb) ...[
            GoRoute(path: '/state-admin', builder: (_, __) => const StateAdminScreen()),
            GoRoute(path: '/superadmin', builder: (_, __) => const SuperadminScreen()),
          ],
        ],
      ),
    ],
  );
});
