class Admin {
  final int id;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      permissions: List<String>.from(json['permissions'] ?? []),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isSuperAdmin => role == 'super_admin';
  bool get isContentAdmin => role == 'content_admin';
  bool get isModerator => role == 'moderator';

  bool canManageContent() {
    return ['super_admin', 'content_admin'].contains(role);
  }

  bool canManageUsers() {
    return role == 'super_admin';
  }

  bool canModerate() {
    return ['super_admin', 'moderator'].contains(role);
  }
}