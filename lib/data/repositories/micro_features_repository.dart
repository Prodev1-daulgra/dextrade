import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_preferences_model.dart';
import '../models/watchlist_item_model.dart';
import '../models/app_notification_model.dart';

/// Preferences, watchlist, notifications, paper orders — graceful when schema not deployed.
class MicroFeaturesRepository {
  final SupabaseClient _client;
  MicroFeaturesRepository(this._client);

  Future<UserPreferencesModel> getPreferences(String email) async {
    try {
      final res = await _client
          .from('user_preferences')
          .select()
          .eq('user_email', email)
          .maybeSingle();
      if (res == null) {
        return UserPreferencesModel(userEmail: email);
      }
      return UserPreferencesModel.fromJson(res);
    } catch (_) {
      return UserPreferencesModel(userEmail: email);
    }
  }

  Future<UserPreferencesModel> upsertPreferences({
    bool? hideBalance,
    bool? hapticsEnabled,
    String? defaultTimeframe,
    String? lastTradePair,
    bool? notifyTrades,
    bool? notifyDeposits,
    String? mirrorSort,
  }) async {
    try {
      final res = await _client.rpc('upsert_user_preferences', params: {
        if (hideBalance != null) 'p_hide_balance': hideBalance,
        if (hapticsEnabled != null) 'p_haptics_enabled': hapticsEnabled,
        if (defaultTimeframe != null) 'p_default_timeframe': defaultTimeframe,
        if (lastTradePair != null) 'p_last_trade_pair': lastTradePair,
        if (notifyTrades != null) 'p_notify_trades': notifyTrades,
        if (notifyDeposits != null) 'p_notify_deposits': notifyDeposits,
        if (mirrorSort != null) 'p_mirror_sort': mirrorSort,
      });
      return UserPreferencesModel.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return UserPreferencesModel.defaults;
    }
  }

  Future<List<WatchlistItemModel>> getWatchlist(String email) async {
    try {
      final res = await _client
          .from('watchlist')
          .select()
          .eq('user_email', email)
          .order('sort_order');
      return (res as List)
          .map((e) => WatchlistItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> toggleWatchlist(String symbol, {String source = 'db'}) async {
    try {
      final added = await _client.rpc('toggle_watchlist', params: {
        'p_symbol': symbol,
        'p_source': source,
      });
      return added as bool;
    } catch (_) {
      return false;
    }
  }

  Future<List<AppNotificationModel>> getNotifications(
    String email, {
    int limit = 30,
  }) async {
    try {
      final res = await _client
          .from('app_notifications')
          .select()
          .eq('user_email', email)
          .order('created_at', ascending: false)
          .limit(limit);
      return (res as List)
          .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _client
          .from('app_notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (_) {}
  }

  Future<void> pushNotification({
    required String title,
    required String body,
    String kind = 'info',
    Map<String, dynamic> meta = const {},
  }) async {
    try {
      await _client.rpc('push_app_notification', params: {
        'p_title': title,
        'p_body': body,
        'p_kind': kind,
        'p_meta': meta,
      });
    } catch (_) {}
  }

  Future<void> createPaperOrder({
    required String email,
    required String pairSymbol,
    required String side,
    required String orderType,
    required double price,
    required double size,
    required int leverage,
    required double marginUsd,
  }) async {
    try {
      await _client.from('trade_orders').insert({
        'user_email': email,
        'pair_symbol': pairSymbol,
        'side': side,
        'order_type': orderType,
        'price': price,
        'size': size,
        'leverage': leverage,
        'margin_usd': marginUsd,
        'status': 'open',
      });
    } catch (_) {}
  }

  Future<void> closePaperOrder(String orderId, double pnlUsd) async {
    try {
      await _client.from('trade_orders').update({
        'status': 'closed',
        'pnl_usd': pnlUsd,
        'closed_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (_) {}
  }

  Stream<List<AppNotificationModel>> watchNotifications(String email) {
    try {
      return _client
          .from('app_notifications')
          .stream(primaryKey: ['id'])
          .eq('user_email', email)
          .order('created_at', ascending: false)
          .map((list) => list
              .map((e) => AppNotificationModel.fromJson(e))
              .toList());
    } catch (_) {
      return Stream.value([]);
    }
  }
}
