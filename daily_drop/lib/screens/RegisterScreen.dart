// lib/screens/RegisterScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
    final st = ref.read(authProvider);
    if (st.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(st.error!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Registered successfully! Please login.')),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // App Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 70,
                      height: 70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join Us Today',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your account to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Registration Form Card
                  Card(
                    elevation: 8,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name Field
                            TextFormField(
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return 'Name is required';
                                if (value.length < 2) return 'Name too short';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Email Field
                            TextFormField(
                              controller: _email,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return 'Email is required';
                                final emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
                                if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Password Field
                            TextFormField(
                              controller: _password,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                helperText: 'Min 6 chars with letters and numbers',
                                helperMaxLines: 2,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              obscureText: _obscure,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                if (v.length < 6) return 'Min 6 characters';
                                final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
                                final hasDigit = RegExp(r'[0-9]').hasMatch(v);
                                if (!(hasLetter && hasDigit)) return 'Use letters and numbers';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Confirm Password Field
                            TextFormField(
                              controller: _confirm,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Confirm your password';
                                if (v != _password.text) return 'Passwords do not match';
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 24),
                            // Register Button
                            FilledButton(
                              onPressed: st.loading ? null : _submit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: st.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: st.loading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Loading Overlay
            if (st.loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/loader.gif',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Creating account...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}