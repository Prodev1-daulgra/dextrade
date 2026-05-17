import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/crypto_model.dart';

class CryptoRepository {
  final SupabaseClient _client;

  CryptoRepository(this._client);

  Future<List<CryptoModel>> getActiveCryptos() async {
    final res = await _client
        .from('cryptocurrencies')
        .select()
        .eq('is_active', true)
        .order('market_cap', ascending: false);
    return (res as List).map((e) => CryptoModel.fromJson(e)).toList();
  }

  Future<CryptoModel?> getCrypto(String symbol) async {
    final res = await _client
        .from('cryptocurrencies')
        .select()
        .eq('symbol', symbol)
        .maybeSingle();
    if (res == null) return null;
    return CryptoModel.fromJson(res);
  }
}
