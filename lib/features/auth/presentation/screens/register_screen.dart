import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/wasla_button.dart';
import '../../../../core/widgets/wasla_glass_card.dart';
import '../../../../core/widgets/wasla_logo.dart';
import '../../../../core/widgets/wasla_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final registerUseCase = ref.read(registerUseCaseProvider);
    final result = await registerUseCase(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _selectedRole,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Create Account')),
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
                  vertical: 20.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: WaslaLogo(
                          fontSize: 48,
                          color: isDark
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start your delivery journey today',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      WaslaGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            WaslaTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              prefixIcon: Icons.person_outline,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 24),
                            Text(
                              'SELECT YOUR ROLE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'customer',
                                  label: Text('Customer'),
                                  icon: Icon(Icons.shopping_bag_outlined),
                                ),
                                ButtonSegment(
                                  value: 'provider',
                                  label: Text('Provider'),
                                  icon: Icon(Icons.local_shipping_outlined),
                                ),
                              ],
                              selected: {_selectedRole},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _selectedRole = newSelection.first;
                                });
                              },
                              style: SegmentedButton.styleFrom(
                                selectedBackgroundColor:
                                    theme.colorScheme.primary,
                                selectedForegroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      WaslaButton(
                        label: 'Sign Up',
                        isLoading: _isLoading,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? '),
                            Text(
                              'Login',
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
