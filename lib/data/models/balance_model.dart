class BalanceModel {
  final String id;
  final String userEmail;
  final double balanceUsd;
  final double totalInvested;
  final double totalProfitLoss;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BalanceModel({
    required this.id,
    required this.userEmail,
    this.balanceUsd = 0,
    this.totalInvested = 0,
    this.totalProfitLoss = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      balanceUsd: _toDouble(json['balance_usd']),
      totalInvested: _toDouble(json['total_invested']),
      totalProfitLoss: _toDouble(json['total_profit_loss']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  BalanceModel copyWith({
    double? balanceUsd,
    double? totalInvested,
    double? totalProfitLoss,
  }) {
    return BalanceModel(
      id: id,
      userEmail: userEmail,
      balanceUsd: balanceUsd ?? this.balanceUsd,
      totalInvested: totalInvested ?? this.totalInvested,
      totalProfitLoss: totalProfitLoss ?? this.totalProfitLoss,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
