// lib/screens/LoginScreen.dart
import 'package:daily_drop/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/auth_provider.dart';
import 'Dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(_email.text.trim(), _password.text);
    final st = ref.read(authProvider);
    if (st.user != null && st.user?.accessToken.isNotEmpty == true && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Dashboard()));
    } else if (st.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(st.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Image.asset('assets/images/app_icon.png', width: 120, height: 120),
                  const SizedBox(height: 16),
                  Text('Welcome back', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: st.loading ? null : _submit,
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: st.loading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  );
                                },
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (st.loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/loader.gif', width: 120, height: 120),
                ),
              ),
          ],
        ),
      ),
    );
  }
}