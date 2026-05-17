class CryptoModel {
  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double marketCap;
  final double volume24h;
  final String iconColor;
  final bool isActive;

  const CryptoModel({
    required this.id,
    required this.symbol,
    required this.name,
    this.price = 0,
    this.change24h = 0,
    this.marketCap = 0,
    this.volume24h = 0,
    this.iconColor = '#A855F7',
    this.isActive = true,
  });

  bool get isPositive => change24h >= 0;

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: _d(json['price']),
      change24h: _d(json['change_24h']),
      marketCap: _d(json['market_cap']),
      volume24h: _d(json['volume_24h']),
      iconColor: json['icon_color'] as String? ?? '#A855F7',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
