class OptionsPositionModel {
  final String id;
  final String userEmail;
  final String underlyingSymbol;
  final String type; // 'call' or 'put'
  final double strikePrice;
  final DateTime expirationDate;
  final double contracts;
  final double premiumPaidUsd;
  final String status; // 'open', 'closed', 'expired_worthless', 'exercised'
  final DateTime createdAt;
  final DateTime updatedAt;

  const OptionsPositionModel({
    required this.id,
    required this.userEmail,
    required this.underlyingSymbol,
    required this.type,
    required this.strikePrice,
    required this.expirationDate,
    required this.contracts,
    required this.premiumPaidUsd,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCall => type == 'call';
  bool get isOpen => status == 'open';

  factory OptionsPositionModel.fromJson(Map<String, dynamic> json) {
    return OptionsPositionModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      underlyingSymbol: json['underlying_symbol'] as String,
      type: json['type'] as String,
      strikePrice: (json['strike_price'] as num).toDouble(),
      expirationDate: DateTime.parse(json['expiration_date'] as String),
      contracts: (json['contracts'] as num).toDouble(),
      premiumPaidUsd: (json['premium_paid_usd'] as num).toDouble(),
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
