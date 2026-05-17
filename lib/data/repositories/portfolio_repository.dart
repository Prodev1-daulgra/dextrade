import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/portfolio_model.dart';
import '../models/stock_portfolio_model.dart';
import '../models/futures_model.dart';
import '../models/options_model.dart';

class PortfolioRepository {
  final SupabaseClient _client;

  PortfolioRepository(this._client);

  Stream<List<PortfolioModel>> watchCryptoPortfolio(String email) {
    return _client
        .from('portfolio')
        .stream(primaryKey: ['id'])
        .eq('user_email', email)
        .map((list) => list.map((e) => PortfolioModel.fromJson(e)).toList());
  }

  Future<List<StockPortfolioModel>> getStockPortfolio(String email) async {
    final res = await _client
        .from('stock_portfolio')
        .select()
        .eq('user_email', email);
    return (res as List).map((e) => StockPortfolioModel.fromJson(e)).toList();
  }

  Future<List<FuturesPositionModel>> getFuturesPositions(String email) async {
    final res = await _client
        .from('futures_positions')
        .select()
        .eq('user_email', email)
        .order('created_at', ascending: false);
    return (res as List).map((e) => FuturesPositionModel.fromJson(e)).toList();
  }

  Future<List<OptionsPositionModel>> getOptionsPositions(String email) async {
    final res = await _client
        .from('options_positions')
        .select()
        .eq('user_email', email)
        .order('created_at', ascending: false);
    return (res as List).map((e) => OptionsPositionModel.fromJson(e)).toList();
  }
}
