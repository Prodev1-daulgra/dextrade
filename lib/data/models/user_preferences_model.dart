class UserPreferencesModel {
  final String userEmail;
  final bool hideBalance;
  final bool hapticsEnabled;
  final String defaultTimeframe;
  final String lastTradePair;
  final bool notifyTrades;
  final bool notifyDeposits;
  final String mirrorSort;

  const UserPreferencesModel({
    required this.userEmail,
    this.hideBalance = false,
    this.hapticsEnabled = true,
    this.defaultTimeframe = '15M',
    this.lastTradePair = 'BTC',
    this.notifyTrades = true,
    this.notifyDeposits = true,
    this.mirrorSort = 'roi',
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userEmail: json['user_email'] as String,
      hideBalance: json['hide_balance'] as bool? ?? false,
      hapticsEnabled: json['haptics_enabled'] as bool? ?? true,
      defaultTimeframe: json['default_timeframe'] as String? ?? '15M',
      lastTradePair: json['last_trade_pair'] as String? ?? 'BTC',
      notifyTrades: json['notify_trades'] as bool? ?? true,
      notifyDeposits: json['notify_deposits'] as bool? ?? true,
      mirrorSort: json['mirror_sort'] as String? ?? 'roi',
    );
  }

  static const defaults = UserPreferencesModel(userEmail: '');
}
