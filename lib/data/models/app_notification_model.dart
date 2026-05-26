class AppNotificationModel {
  final String id;
  final String userEmail;
  final String title;
  final String body;
  final String kind;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.body,
    required this.kind,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      userEmail: json['user_email'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      kind: json['kind'] as String? ?? 'info',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
