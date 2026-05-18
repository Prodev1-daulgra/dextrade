import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/copy_trade_model.dart';

class CopyTradeRepository {
  final SupabaseClient _client;

  CopyTradeRepository(this._client);

  Future<List<CopyTraderModel>> getActiveTraders() async {
    final res = await _client
        .from('copy_traders')
        .select()
        .eq('status', 'active')
        .order('total_profit_pct', ascending: false);
    return (res as List).map((e) => CopyTraderModel.fromJson(e)).toList();
  }

  Future<List<CopyTradeModel>> getUserCopyTrades(String email) async {
    final res = await _client
        .from('copy_trades')
        .select()
        .eq('user_email', email)
        .order('created_at', ascending: false);
    return (res as List).map((e) => CopyTradeModel.fromJson(e)).toList();
  }

  Future<CopyTradeModel> initializeMirror(
    String email,
    CopyTraderModel trader,
  ) async {
    final res = await _client
        .from('copy_trades')
        .insert({
          'user_email': email,
          'trader_id': trader.id,
          'trader_name': trader.traderName,
          'allocation': trader.minAllocation,
          'status': 'pending',
        })
        .select()
        .single();
    return CopyTradeModel.fromJson(res);
  }

  Future<void> terminateMirror(String copyTradeId) async {
    await _client.from('copy_trades').delete().eq('id', copyTradeId);
  }

  Future<void> approveCopyTrade(String tradeId) async {
    final tx = await _client
        .from('copy_trades')
        .select()
        .eq('id', tradeId)
        .single();
    if (tx['status'] != 'pending')
      throw Exception('Copy trade already ${tx['status']}');

    final bal = await _client
        .from('user_balances')
        .select()
        .eq('user_email', tx['user_email'])
        .single();
    final amount = (tx['allocation'] as num).toDouble();
    final currentBalance = (bal['balance_usd'] as num).toDouble();

    if (currentBalance < amount) {
      await _client
          .from('copy_trades')
          .update({'status': 'rejected'})
          .eq('id', tradeId);
      throw Exception('Insufficient funds. Auto-rejected.');
    }

    await _client
        .from('copy_trades')
        .update({
          'status': 'approved',
          'is_active': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', tradeId)
        .eq('status', 'pending');

    await _client
        .from('user_balances')
        .update({
          'balance_usd': currentBalance - amount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bal['id']);
  }
}
