import 'dart:convert';

class UserModel {
  final int? id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatar;
  final String passwordHash;
  final bool isBlocked;
  final String role;
  final List<String>? permissions;
  final String status;
  final DateTime? lastLogin;
  final DateTime? lastActivity;
  final int loginCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.avatar,
    required this.passwordHash,
    this.isBlocked = false,
    required this.role,
    this.permissions,
    this.status = 'active',
    this.lastLogin,
    this.lastActivity,
    this.loginCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'password_hash': passwordHash,
      'is_blocked': isBlocked ? 1 : 0,
      'role': role,
      'permissions': permissions != null ? jsonEncode(permissions) : null,
      'status': status,
      'last_login': lastLogin?.toIso8601String(),
      'last_activity': lastActivity?.toIso8601String(),
      'login_count': loginCount,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at':
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      phone: map['phone'],
      avatar: map['avatar'],
      passwordHash: map['password_hash'],
      isBlocked: map['is_blocked'] == 1,
      role: map['role'],
      permissions: map['permissions'] != null
          ? List<String>.from(jsonDecode(map['permissions']))
          : null,
      status: map['status'],
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'])
          : null,
      lastActivity: map['last_activity'] != null
          ? DateTime.parse(map['last_activity'])
          : null,
      loginCount: map['login_count'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}
