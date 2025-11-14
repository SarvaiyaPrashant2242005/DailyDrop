// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/auth_model.dart';

class AuthService {
  final String baseUrl;
  AuthService({required this.baseUrl});

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return AuthUser.fromJson(data);
    }
    throw Exception(_readError(res));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? role, // optional; server defaults to 'admin'
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    final body = {
      'name': name,
      'email': email,
      'password': password,
      if (role != null) 'role': role,
    };
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 201) return;
    throw Exception(_readError(res));
  }

  String _readError(http.Response res) {
    try {
      final m = jsonDecode(res.body);
      if (m is Map && m['message'] is String) return m['message'];
    } catch (_) {}
    return 'Request failed (${res.statusCode})';
  }
}