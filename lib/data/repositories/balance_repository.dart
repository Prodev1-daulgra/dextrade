import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/balance_model.dart';

class BalanceRepository {
  final SupabaseClient _client;

  BalanceRepository(this._client);

  Future<BalanceModel?> getUserBalance(String email) async {
    final res = await _client
        .from('user_balances')
        .select()
        .eq('user_email', email)
        .maybeSingle();
    if (res == null) return null;
    return BalanceModel.fromJson(res);
  }

  Future<void> updateBalance(
    String balanceId, {
    double? balanceUsd,
    double? totalInvested,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (balanceUsd != null) updates['balance_usd'] = balanceUsd;
    if (totalInvested != null) updates['total_invested'] = totalInvested;
    await _client.from('user_balances').update(updates).eq('id', balanceId);
  }

  /// Subscribe to realtime balance changes
  RealtimeChannel subscribeToBalance(
    String email,
    void Function(dynamic) onUpdate,
  ) {
    return _client
        .channel('balance:$email')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'user_balances',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_email',
            value: email,
          ),
          callback: (payload) => onUpdate(payload),
        )
        .subscribe();
  }
}
