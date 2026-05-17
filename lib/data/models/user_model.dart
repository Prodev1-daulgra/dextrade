class UserModel {
  final String id;
  final String? authId;
  final String email;
  final String? fullName;
  final String? walletAddress;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    this.authId,
    required this.email,
    this.fullName,
    this.walletAddress,
    this.role = 'user',
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isSuperAdmin => email == 'tonyokezie10@gmail.com' && isAdmin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      walletAddress: json['wallet_address'] as String?,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'auth_id': authId,
    'email': email,
    'full_name': fullName,
    'wallet_address': walletAddress,
    'role': role,
    'status': status,
  };
}
