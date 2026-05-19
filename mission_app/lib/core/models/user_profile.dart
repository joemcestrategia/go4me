enum UserRole {
  donor,
  missionary,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'missionary':
        return UserRole.missionary;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.donor;
    }
  }

  String get name => toString().split('.').last;
}

class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final UserRole role;
  final String? country;
  final String? slug;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
    this.country,
    this.slug,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      country: json['country'] as String?,
      slug: json['slug'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['full_name']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
      role: UserRole.fromString(map['role']?.toString()),
      country: map['country']?.toString(),
      slug: map['slug']?.toString(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'country': country,
      'slug': slug,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    String? country,
    String? slug,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      country: country ?? this.country,
      slug: slug ?? this.slug,
      createdAt: createdAt,
    );
  }
}
