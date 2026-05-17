import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/balance_model.dart';

class TransactionRepository {
  final SupabaseClient _client;

  TransactionRepository(this._client);

  Future<List<TransactionModel>> getUserTransactions(String email, {int limit = 50}) async {
    final res = await _client
        .from('transactions')
        .select()
        .eq('user_email', email)
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel> createDeposit(String email, double amount) async {
    final res = await _client.from('transactions').insert({
      'user_email': email,
      'type': 'deposit',
      'amount': amount,
      'status': 'pending',
      'notes': 'Deposit request for \$${amount.toStringAsFixed(2)}',
    }).select().single();
    return TransactionModel.fromJson(res);
  }

  Future<TransactionModel> createWithdrawal(String email, double amount, String wallet) async {
    final res = await _client.from('transactions').insert({
      'user_email': email,
      'type': 'withdrawal',
      'amount': amount,
      'wallet_address': wallet,
      'status': 'pending',
      'notes': 'Withdrawal request for \$${amount.toStringAsFixed(2)}',
    }).select().single();
    return TransactionModel.fromJson(res);
  }

  Future<TransactionModel> createBuyOrder(String email, double amountUsd, String cryptoSymbol, double cryptoAmount) async {
    final res = await _client.from('transactions').insert({
      'user_email': email,
      'type': 'buy',
      'amount': amountUsd,
      'crypto_symbol': cryptoSymbol,
      'crypto_amount': cryptoAmount,
      'status': 'pending',
      'notes': 'Buy \$${amountUsd.toStringAsFixed(2)} $cryptoSymbol',
    }).select().single();
    return TransactionModel.fromJson(res);
  }

  Future<TransactionModel> createSellOrder(String email, double amountUsd, String cryptoSymbol, double cryptoAmount) async {
    final res = await _client.from('transactions').insert({
      'user_email': email,
      'type': 'sell',
      'amount': amountUsd,
      'crypto_symbol': cryptoSymbol,
      'crypto_amount': cryptoAmount,
      'status': 'pending',
      'notes': 'Sell $cryptoAmount $cryptoSymbol',
    }).select().single();
    return TransactionModel.fromJson(res);
  }

  /// State Admin Portal: Approve transaction and update balance
  Future<void> approveTransaction(String txId) async {
    // 1. Fetch & validate
    final tx = await _client.from('transactions').select().eq('id', txId).single();
    if (tx['status'] != 'pending') throw Exception('Transaction is already ${tx['status']}');

    // 2. Lock: mark approved first
    await _client
        .from('transactions')
        .update({'status': 'approved', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', txId)
        .eq('status', 'pending');

    // 3. Fetch balance
    final bal = await _client
        .from('user_balances')
        .select()
        .eq('user_email', tx['user_email'])
        .single();

    final amount = (tx['amount'] as num).toDouble();
    double newBalance = (bal['balance_usd'] as num).toDouble();
    double newInvested = (bal['total_invested'] as num).toDouble();

    if (tx['type'] == 'deposit') {
      newBalance += amount;
      newInvested += amount;
    } else if (tx['type'] == 'withdrawal') {
      if (newBalance < amount) throw Exception('Insufficient funds');
      newBalance -= amount;
    } else if (tx['type'] == 'buy') {
      if (newBalance < amount) throw Exception('Insufficient balance');
      newBalance -= amount;
      newInvested += amount;
      
      // Update or insert portfolio
      final cryptoSymbol = tx['crypto_symbol'];
      final cryptoAmount = (tx['crypto_amount'] as num).toDouble();
      
      final currentPortfolio = await _client
          .from('portfolio')
          .select()
          .eq('user_email', tx['user_email'])
          .eq('crypto_symbol', cryptoSymbol)
          .maybeSingle();
          
      if (currentPortfolio != null) {
        final currentAmount = (currentPortfolio['amount'] as num).toDouble();
        final currentAvgPrice = (currentPortfolio['avg_buy_price'] as num).toDouble();
        
        final newTotalAmount = currentAmount + cryptoAmount;
        final newAvgPrice = ((currentAmount * currentAvgPrice) + amount) / newTotalAmount;
        
        await _client.from('portfolio').update({
          'amount': newTotalAmount,
          'avg_buy_price': newAvgPrice,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentPortfolio['id']);
      } else {
        await _client.from('portfolio').insert({
          'user_email': tx['user_email'],
          'crypto_symbol': cryptoSymbol,
          'amount': cryptoAmount,
          'avg_buy_price': amount / cryptoAmount,
        });
      }
    } else if (tx['type'] == 'sell') {
      newBalance += amount;
      
      final cryptoSymbol = tx['crypto_symbol'];
      final cryptoAmountToSell = (tx['crypto_amount'] as num).toDouble();
      
      final currentPortfolio = await _client
          .from('portfolio')
          .select()
          .eq('user_email', tx['user_email'])
          .eq('crypto_symbol', cryptoSymbol)
          .maybeSingle();
          
      if (currentPortfolio == null || (currentPortfolio['amount'] as num).toDouble() < cryptoAmountToSell) {
        throw Exception('Insufficient crypto balance');
      }
      
      final newAmount = (currentPortfolio['amount'] as num).toDouble() - cryptoAmountToSell;
      if (newAmount <= 0) {
        await _client.from('portfolio').delete().eq('id', currentPortfolio['id']);
      } else {
        await _client.from('portfolio').update({
          'amount': newAmount,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentPortfolio['id']);
      }
    }

    // 4. Write new balance
    await _client.from('user_balances').update({
      'balance_usd': newBalance < 0 ? 0 : newBalance,
      'total_invested': newInvested < 0 ? 0 : newInvested,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bal['id']);
  }

  /// State Admin Portal: Reject transaction
  Future<void> rejectTransaction(String txId) async {
    await _client
        .from('transactions')
        .update({'status': 'rejected', 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', txId);
  }

  /// Subscribe to realtime transaction changes
  RealtimeChannel subscribeToTransactions(String email, void Function(dynamic) onUpdate) {
    return _client
        .channel('transactions:$email')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_email', value: email),
          callback: (payload) => onUpdate(payload),
        )
        .subscribe();
  }
}
