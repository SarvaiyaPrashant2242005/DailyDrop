// lib/model/auth_model.dart
class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String accessToken;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      accessToken: json['accessToken'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'accessToken': accessToken,
      };
}