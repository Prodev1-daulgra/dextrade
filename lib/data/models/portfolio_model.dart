class PortfolioModel {
  final String id;
  final String userEmail;
  final String cryptoSymbol;
  final double amount;
  final double avgBuyPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PortfolioModel({
    required this.id,
    required this.userEmail,
    required this.cryptoSymbol,
    required this.amount,
    required this.avgBuyPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalValue => amount * avgBuyPrice;

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      cryptoSymbol: json['crypto_symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
      avgBuyPrice: (json['avg_buy_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_email': userEmail,
    'crypto_symbol': cryptoSymbol,
    'amount': amount,
    'avg_buy_price': avgBuyPrice,
  };
}
