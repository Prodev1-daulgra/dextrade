class StockPortfolioModel {
  final String id;
  final String userEmail;
  final String stockSymbol;
  final double shares;
  final double avgBuyPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockPortfolioModel({
    required this.id,
    required this.userEmail,
    required this.stockSymbol,
    required this.shares,
    required this.avgBuyPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalValue => shares * avgBuyPrice;

  factory StockPortfolioModel.fromJson(Map<String, dynamic> json) {
    return StockPortfolioModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      stockSymbol: json['stock_symbol'] as String,
      shares: (json['shares'] as num).toDouble(),
      avgBuyPrice: (json['avg_buy_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
