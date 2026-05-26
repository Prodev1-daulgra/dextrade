import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/supabase_client.dart';
import '../data/models/user_model.dart';
import '../data/models/balance_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/copy_trade_model.dart';
import '../data/models/crypto_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/balance_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/copy_trade_repository.dart';
import '../data/repositories/crypto_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/portfolio_repository.dart';
import '../data/repositories/platform_settings_repository.dart';
import '../data/repositories/coingecko_repository.dart';
import '../data/repositories/micro_features_repository.dart';
import '../data/models/user_preferences_model.dart';
import '../data/models/watchlist_item_model.dart';
import '../data/models/app_notification_model.dart';
import '../data/models/portfolio_model.dart';
import '../data/models/futures_model.dart';
import '../data/models/options_model.dart';
import '../data/models/stock_portfolio_model.dart';

// ─── Repository Providers ───
final supabaseProvider = Provider<SupabaseClient>((_) => SupabaseConfig.client);

final authRepoProvider = Provider(
  (ref) => AuthRepository(ref.read(supabaseProvider)),
);
final balanceRepoProvider = Provider(
  (ref) => BalanceRepository(ref.read(supabaseProvider)),
);
final txRepoProvider = Provider(
  (ref) => TransactionRepository(ref.read(supabaseProvider)),
);
final copyTradeRepoProvider = Provider(
  (ref) => CopyTradeRepository(ref.read(supabaseProvider)),
);
final cryptoRepoProvider = Provider(
  (ref) => CryptoRepository(ref.read(supabaseProvider)),
);
final coinGeckoRepoProvider = Provider((_) => CoinGeckoRepository());
final userRepoProvider = Provider(
  (ref) => UserRepository(ref.read(supabaseProvider)),
);
final portfolioRepoProvider = Provider(
  (ref) => PortfolioRepository(ref.read(supabaseProvider)),
);
final platformSettingsRepoProvider = Provider(
  (ref) => PlatformSettingsRepository(ref.read(supabaseProvider)),
);
final microFeaturesRepoProvider = Provider(
  (ref) => MicroFeaturesRepository(ref.read(supabaseProvider)),
);

// ─── Auth State ───
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = true, this.error});

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isSuperAdmin => user?.isSuperAdmin ?? false;
  String? get email => user?.email;

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  StreamSubscription? _authSub;

  AuthNotifier(this._authRepo) : super(const AuthState()) {
    _init();
  }

  UserModel _fallbackUserFromAuth(User user) {
    final email = user.email ?? '';
    final createdAt = DateTime.tryParse(user.createdAt) ?? DateTime.now();
    // For MVP: superadmin is email-gated; role column is still DB-driven when available.
    final role = email == 'tonyokezie10@gmail.com' ? 'admin' : 'user';
    return UserModel(
      id: user.id,
      authId: user.id,
      email: email,
      fullName: (user.userMetadata?['full_name'] as String?) ??
          (email.contains('@') ? email.split('@').first : null),
      role: role,
      status: 'active',
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _init() async {
    try {
      // If the RPC exists, ensure app rows exist before reading profile.
      if (_authRepo.currentAuthUser != null) {
        await _authRepo.ensureProfile();
      }
      final profile = await _authRepo.getCurrentProfile();
      final authUser = _authRepo.currentAuthUser;
      state = AuthState(
        user: profile ?? (authUser != null ? _fallbackUserFromAuth(authUser) : null),
        isLoading: false,
        error: profile == null && authUser != null
            ? 'Profile table not ready. Deploy Supabase schema (users + trigger) for realtime data.'
            : null,
      );
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }

    _authSub = _authRepo.authStateChanges.listen((event) async {
      if (event.session?.user != null) {
        await _authRepo.ensureProfile();
        final profile = await _authRepo.getUserProfile(
          event.session!.user.email!,
        );
        state = AuthState(
          user: profile ?? _fallbackUserFromAuth(event.session!.user),
          isLoading: false,
          error: profile == null
              ? 'Profile table not ready. Deploy Supabase schema (users + trigger) for realtime data.'
              : null,
        );
      } else {
        state = const AuthState(isLoading: false);
      }
    });
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepo.login(email, password);
      await _authRepo.ensureProfile();
      final profile = await _authRepo.getUserProfile(email);
      final authUser = _authRepo.currentAuthUser;
      state = AuthState(
        user: profile ?? (authUser != null ? _fallbackUserFromAuth(authUser) : null),
        isLoading: false,
        error: profile == null
            ? 'Profile table not ready. Deploy Supabase schema (users + trigger) for realtime data.'
            : null,
      );
      return null;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return e.toString();
    }
  }

  Future<String?> register(
    String email,
    String password, {
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepo.register(email, password, fullName: fullName);
      // Profile may be auto-created by DB trigger; also try RPC if installed.
      await Future.delayed(const Duration(milliseconds: 400));
      await _authRepo.ensureProfile();
      final profile = await _authRepo.getUserProfile(email);
      final authUser = _authRepo.currentAuthUser;
      state = AuthState(
        user: profile ?? (authUser != null ? _fallbackUserFromAuth(authUser) : null),
        isLoading: false,
        error: profile == null
            ? 'Profile table not ready. Deploy Supabase schema (users + trigger) for realtime data.'
            : null,
      );
      return null;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = const AuthState(isLoading: false);
  }

  Future<void> refreshProfile() async {
    final email = state.user?.email ?? _authRepo.currentEmail;
    if (email == null) return;
    final profile = await _authRepo.getUserProfile(email);
    if (profile != null) {
      state = AuthState(user: profile, isLoading: false);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepoProvider));
});

// ─── Balance Provider (Real-time) ───
final balanceProvider = StreamProvider.family<BalanceModel?, String>((
  ref,
  email,
) {
  final client = ref.read(supabaseProvider);
  return client
      .from('user_balances')
      .stream(primaryKey: ['id'])
      .eq('user_email', email)
      .map((list) {
        if (list.isEmpty) return null;
        return BalanceModel.fromJson(list.first);
      });
});

// ─── Transaction Provider (Real-time) ───
final transactionsProvider =
    StreamProvider.family<List<TransactionModel>, String>((ref, email) {
      final client = ref.read(supabaseProvider);
      return client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .eq('user_email', email)
          .order('created_at', ascending: false)
          .map(
            (list) => list.map((e) => TransactionModel.fromJson(e)).toList(),
          );
    });

// ─── Crypto Provider ───
final cryptosProvider = FutureProvider<List<CryptoModel>>((ref) async {
  return ref.read(cryptoRepoProvider).getActiveCryptos();
});

/// Public market pulse fallback when Supabase market tables are empty/unseeded.
final coinGeckoTopMarketsProvider =
    FutureProvider<List<CoinGeckoMarketToken>>((ref) async {
  return ref.read(coinGeckoRepoProvider).getTopMarkets(perPage: 10);
});

// ─── Copy Trading Providers ───
final copyTradersProvider = FutureProvider<List<CopyTraderModel>>((ref) async {
  return ref.read(copyTradeRepoProvider).getActiveTraders();
});

final userCopyTradesProvider =
    StreamProvider.family<List<CopyTradeModel>, String>((ref, email) {
      final client = ref.read(supabaseProvider);
      return client
          .from('copy_trades')
          .stream(primaryKey: ['id'])
          .eq('user_email', email)
          .order('created_at', ascending: false)
          .map((list) => list.map((e) => CopyTradeModel.fromJson(e)).toList());
    });

// ─── Portfolio Providers ───
final portfolioProvider = StreamProvider.family<List<PortfolioModel>, String>((
  ref,
  email,
) {
  return ref.read(portfolioRepoProvider).watchCryptoPortfolio(email);
});

final futuresProvider =
    FutureProvider.family<List<FuturesPositionModel>, String>((
      ref,
      email,
    ) async {
      return ref.read(portfolioRepoProvider).getFuturesPositions(email);
    });

final optionsProvider =
    FutureProvider.family<List<OptionsPositionModel>, String>((
      ref,
      email,
    ) async {
      return ref.read(portfolioRepoProvider).getOptionsPositions(email);
    });

final stockPortfolioProvider =
    FutureProvider.family<List<StockPortfolioModel>, String>((
      ref,
      email,
    ) async {
      return ref.read(portfolioRepoProvider).getStockPortfolio(email);
    });

// ─── Superadmin: All Users ───
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.read(userRepoProvider).getAllUsers();
});

// ─── Micro-features (preferences, watchlist, notifications) ───
final userPreferencesProvider =
    FutureProvider.family<UserPreferencesModel, String>((ref, email) async {
  return ref.read(microFeaturesRepoProvider).getPreferences(email);
});

final watchlistProvider =
    FutureProvider.family<List<WatchlistItemModel>, String>((ref, email) async {
  return ref.read(microFeaturesRepoProvider).getWatchlist(email);
});

final appNotificationsProvider =
    StreamProvider.family<List<AppNotificationModel>, String>((ref, email) {
  return ref.read(microFeaturesRepoProvider).watchNotifications(email);
});

final unreadNotificationsCountProvider =
    Provider.family<int, String>((ref, email) {
  final async = ref.watch(appNotificationsProvider(email));
  return async.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
