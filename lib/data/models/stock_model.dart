class StockModel {
  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double marketCap;
  final double volume24h;
  final String sector;
  final String exchange;
  final String iconColor;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.marketCap,
    required this.volume24h,
    required this.sector,
    required this.exchange,
    required this.iconColor,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      change24h: (json['change_24h'] as num).toDouble(),
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      volume24h: (json['volume_24h'] as num?)?.toDouble() ?? 0,
      sector: json['sector'] as String? ?? 'Technology',
      exchange: json['exchange'] as String? ?? 'NASDAQ',
      iconColor: json['icon_color'] as String? ?? '#6366f1',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
