import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/wasla_button.dart';
import '../../../../core/widgets/wasla_glass_card.dart';
import '../../../../core/widgets/wasla_logo.dart';
import '../../../../core/widgets/wasla_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        SnackbarUtils.showError(context, message: failure.message);
      },
      (user) {
        // Navigation is handled by the Router redirect
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF0F172A),
                        const Color(0xFF1E1B4B),
                        const Color(0xFF312E81),
                      ]
                    : [
                        const Color(0xFFEEF2FF),
                        const Color(0xFFE0E7FF),
                        const Color(0xFFC7D2FE),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: WaslaLogo(
                          fontSize: 64,
                          color: isDark
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Delivery Made Simple',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      WaslaGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            WaslaTextField(
                              controller: _emailController,
                              label: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value == null || !value.contains('@')
                                  ? 'Enter a valid email'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            WaslaTextField(
                              controller: _passwordController,
                              label: 'Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) =>
                                  value == null || value.length < 6
                                  ? 'Password too short'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      WaslaButton(
                        label: 'Login',
                        isLoading: _isLoading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account? '),
                            Text(
                              'Register',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
    );
  }
}
