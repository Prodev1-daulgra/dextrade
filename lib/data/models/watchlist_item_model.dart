class WatchlistItemModel {
  final String id;
  final String userEmail;
  final String symbol;
  final String source;
  final int sortOrder;

  WatchlistItemModel({
    required this.id,
    required this.userEmail,
    required this.symbol,
    required this.source,
    required this.sortOrder,
  });

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      symbol: json['symbol'] as String,
      source: json['source'] as String? ?? 'db',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
