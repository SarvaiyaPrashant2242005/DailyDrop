// lib/controller/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/auth_provider.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<void> init() => ref.read(authProvider.notifier).initFromStorage();
  Future<void> login(String email, String password) =>
      ref.read(authProvider.notifier).login(email, password);
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? role,
  }) =>
      ref.read(authProvider.notifier)
          .register(name: name, email: email, password: password, role: role);
  Future<void> logout() => ref.read(authProvider.notifier).logout();
}