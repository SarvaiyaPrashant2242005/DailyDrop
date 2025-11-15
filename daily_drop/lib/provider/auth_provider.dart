// lib/provider/auth_provider.dart
import 'dart:convert';
import 'package:daily_drop/screens/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/auth_model.dart';

class AuthState {
  final bool loading;
  final AuthUser? user;
  final String? error;
  const AuthState({this.loading = false, this.user, this.error});

  AuthState copyWith({bool? loading, AuthUser? user, String? error}) {
    return AuthState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  // Set base URL here
  const baseUrl = 'https://dailydrop-3d5q.onrender.com';
  return AuthService(baseUrl: baseUrl);
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AuthState());

  static const _kUser = 'auth_user';
  static const _kToken = 'access_token';

  Future<void> initFromStorage() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kUser);
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      state = state.copyWith(user: AuthUser.fromJson(m));
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final svc = ref.read(authServiceProvider);
      final user = await svc.login(email: email, password: password);
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kUser, jsonEncode(user.toJson()));
      await sp.setString(_kToken, user.accessToken);
      state = state.copyWith(loading: false, user: user, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final svc = ref.read(authServiceProvider);
      await svc.register(name: name, email: email, password: password, role: role);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kUser);
    await sp.remove(_kToken);
    state = const AuthState();
  }

  Future<bool> hasToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken) != null;
  }
}