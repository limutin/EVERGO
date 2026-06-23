/// User roles
enum UserRole { commuter, driver }

/// User model
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.commuter,
      ),
      avatarUrl: map['avatarUrl'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Mock instances for UI preview
  static UserModel mockCommuter = UserModel(
    id: 'u001',
    name: 'Maria Santos',
    email: 'maria.santos@email.com',
    phone: '+63 912 345 6789',
    role: UserRole.commuter,
    isVerified: true,
    createdAt: DateTime(2024, 3, 15),
  );

  static UserModel mockDriver = UserModel(
    id: 'u002',
    name: 'Juan dela Cruz',
    email: 'juan.delacruz@evergo.ph',
    phone: '+63 917 654 3210',
    role: UserRole.driver,
    isVerified: true,
    createdAt: DateTime(2023, 11, 1),
  );
}
