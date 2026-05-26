import 'dart:convert';
import 'package:http/http.dart' as http;

class CoinGeckoMarketToken {
  final String id;
  final String symbol;
  final String name;
  final double currentPrice;
  final double priceChangePercentage24h;
  final List<double> sparkline7d;

  const CoinGeckoMarketToken({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.sparkline7d,
  });

  bool get isPositive => priceChangePercentage24h >= 0;
}

class CoinGeckoRepository {
  static const _base = 'https://api.coingecko.com/api/v3';
  final http.Client _client;

  CoinGeckoRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<CoinGeckoMarketToken>> getTopMarkets({
    int perPage = 10,
    String vsCurrency = 'usd',
  }) async {
    final uri = Uri.parse('$_base/coins/markets').replace(
      queryParameters: {
        'vs_currency': vsCurrency,
        'order': 'market_cap_desc',
        'per_page': perPage.toString(),
        'page': '1',
        'sparkline': 'true',
        'price_change_percentage': '24h',
      },
    );

    final res = await _client.get(
      uri,
      headers: const {
        'accept': 'application/json',
      },
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('CoinGecko markets failed: ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) return const [];

    return decoded.map<CoinGeckoMarketToken>((raw) {
      final m = (raw as Map).cast<String, dynamic>();
      final spark = (m['sparkline_in_7d'] as Map?)?.cast<String, dynamic>();
      final prices = (spark?['price'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const <double>[];

      return CoinGeckoMarketToken(
        id: (m['id'] ?? '').toString(),
        symbol: (m['symbol'] ?? '').toString().toUpperCase(),
        name: (m['name'] ?? '').toString(),
        currentPrice: (m['current_price'] as num?)?.toDouble() ?? 0,
        priceChangePercentage24h:
            (m['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
        sparkline7d: prices,
      );
    }).toList();
  }
}

