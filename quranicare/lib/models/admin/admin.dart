class Admin {
  final int id;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic>? permissions;
  final DateTime? lastLoginAt;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.permissions,
    this.lastLoginAt,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      permissions: json['permissions'] is String 
          ? {} // Handle string permissions for now
          : json['permissions'],
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods for role checking
  bool get isSuperAdmin => role == 'super_admin';
  bool get isContentAdmin => role == 'content_admin';
  bool get isModerator => role == 'moderator';
  
  bool canManageContent() {
    return isSuperAdmin || isContentAdmin;
  }
  
  bool canModerate() {
    return isSuperAdmin || isContentAdmin || isModerator;
  }
  
  bool canManageAdmins() {
    return isSuperAdmin;
  }
}