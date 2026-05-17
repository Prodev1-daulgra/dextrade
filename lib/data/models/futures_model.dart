class FuturesPositionModel {
  final String id;
  final String userEmail;
  final String cryptoSymbol;
  final String side; // 'long' or 'short'
  final int leverage;
  final double marginUsd;
  final double entryPrice;
  final double liquidationPrice;
  final double sizeUsd;
  final double unrealizedPnl;
  final String status; // 'open', 'closed', 'liquidated'
  final DateTime createdAt;
  final DateTime updatedAt;

  const FuturesPositionModel({
    required this.id,
    required this.userEmail,
    required this.cryptoSymbol,
    required this.side,
    required this.leverage,
    required this.marginUsd,
    required this.entryPrice,
    required this.liquidationPrice,
    required this.sizeUsd,
    required this.unrealizedPnl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen => status == 'open';
  bool get isLong => side == 'long';

  double get pnlPercent => marginUsd > 0 ? (unrealizedPnl / marginUsd) * 100 : 0;

  factory FuturesPositionModel.fromJson(Map<String, dynamic> json) {
    return FuturesPositionModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      cryptoSymbol: json['crypto_symbol'] as String,
      side: json['side'] as String,
      leverage: (json['leverage'] as num).toInt(),
      marginUsd: (json['margin_usd'] as num).toDouble(),
      entryPrice: (json['entry_price'] as num).toDouble(),
      liquidationPrice: (json['liquidation_price'] as num).toDouble(),
      sizeUsd: (json['size_usd'] as num).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
