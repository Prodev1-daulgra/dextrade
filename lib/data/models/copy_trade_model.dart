class CopyTraderModel {
  final String id;
  final String traderName;
  final String? specialty;
  final double totalProfitPct;
  final double winRate;
  final int totalTrades;
  final int followers;
  final double profitSplitPct;
  final double minAllocation;
  final bool isApproved;
  final String status;
  final String riskLevel;
  final String avatarColor;
  final DateTime createdAt;

  const CopyTraderModel({
    required this.id,
    required this.traderName,
    this.specialty,
    this.totalProfitPct = 0,
    this.winRate = 0,
    this.totalTrades = 0,
    this.followers = 0,
    this.profitSplitPct = 20,
    this.minAllocation = 100,
    this.isApproved = false,
    this.status = 'active',
    this.riskLevel = 'medium',
    this.avatarColor = '#A855F7',
    required this.createdAt,
  });

  factory CopyTraderModel.fromJson(Map<String, dynamic> json) {
    return CopyTraderModel(
      id: json['id'] as String,
      traderName: json['trader_name'] as String,
      specialty: json['specialty'] as String?,
      totalProfitPct: _d(json['total_profit_pct']),
      winRate: _d(json['win_rate']),
      totalTrades: (json['total_trades'] as num?)?.toInt() ?? 0,
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      profitSplitPct: _d(json['profit_split_pct']),
      minAllocation: _d(json['min_allocation']),
      isApproved: json['is_approved'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      riskLevel: json['risk_level'] as String? ?? 'medium',
      avatarColor: json['avatar_color'] as String? ?? '#A855F7',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class CopyTradeModel {
  final String id;
  final String userEmail;
  final String traderId;
  final String traderName;
  final double allocation;
  final double profitLoss;
  final double profitLossPct;
  final String status;
  final bool isActive;
  final DateTime createdAt;

  const CopyTradeModel({
    required this.id,
    required this.userEmail,
    required this.traderId,
    required this.traderName,
    this.allocation = 0,
    this.profitLoss = 0,
    this.profitLossPct = 0,
    this.status = 'pending',
    this.isActive = false,
    required this.createdAt,
  });

  factory CopyTradeModel.fromJson(Map<String, dynamic> json) {
    return CopyTradeModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      traderId: json['trader_id'] as String,
      traderName: json['trader_name'] as String? ?? 'Unknown',
      allocation: CopyTraderModel._d(json['allocation']),
      profitLoss: CopyTraderModel._d(json['profit_loss']),
      profitLossPct: CopyTraderModel._d(json['profit_loss_pct']),
      status: json['status'] as String? ?? 'pending',
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
