import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/presentation/screens/create_order_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/wallet_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../core/widgets/wasla_logo.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _StreamRouterRefresh(
      authState.asData?.value != null,
      ref,
    ), // Simplistic refresh trigger
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      // Loading state check could be better handled, but for now:
      if (authState.isLoading) return null; // Don't redirect while loading

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isLoggedIn &&
          (isLoggingIn || isRegistering || state.uri.toString() == '/')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/create-order',
        builder: (context, state) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/chat/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return ChatScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
    ],
  );
});

// Helper to trigger Router refresh on steam change
class _StreamRouterRefresh extends ChangeNotifier {
  _StreamRouterRefresh(bool initialData, Ref ref) {
    ref.listen(authStateChangesProvider, (previous, next) {
      notifyListeners();
    });
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF312E81)]
                : [const Color(0xFFEEF2FF), const Color(0xFFC7D2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WaslaLogo(
              fontSize: 64,
              color: isDark ? Colors.white : theme.colorScheme.primary,
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
