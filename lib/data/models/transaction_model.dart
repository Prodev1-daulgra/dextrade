class TransactionModel {
  final String id;
  final String userEmail;
  final String type;
  final double amount;
  final String? cryptoSymbol;
  final String? stockSymbol;
  final double? cryptoAmount;
  final double? shares;
  final String status;
  final String? notes;
  final String? walletAddress;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.userEmail,
    required this.type,
    required this.amount,
    this.cryptoSymbol,
    this.stockSymbol,
    this.cryptoAmount,
    this.shares,
    this.status = 'pending',
    this.notes,
    this.walletAddress,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved' || status == 'completed';
  bool get isRejected => status == 'rejected';
  bool get isDeposit => type == 'deposit';
  bool get isWithdrawal => type == 'withdrawal';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      type: json['type'] as String,
      amount: _toDouble(json['amount']),
      cryptoSymbol: json['crypto_symbol'] as String?,
      stockSymbol: json['stock_symbol'] as String?,
      cryptoAmount: json['crypto_amount'] != null ? _toDouble(json['crypto_amount']) : null,
      shares: json['shares'] != null ? _toDouble(json['shares']) : null,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      walletAddress: json['wallet_address'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_email': userEmail,
    'type': type,
    'amount': amount,
    if (cryptoSymbol != null) 'crypto_symbol': cryptoSymbol,
    if (walletAddress != null) 'wallet_address': walletAddress,
    'status': status,
    if (notes != null) 'notes': notes,
  };

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
