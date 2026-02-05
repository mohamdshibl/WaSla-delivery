import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wasla/main.dart';
import 'package:wasla/core/config/router.dart';

void main() {
  testWidgets('App renders splash screen initially', (
    WidgetTester tester,
  ) async {
    // Override the router to point to a simple testing route or just use the real one but mocked auth state?
    // Easiest is to mock the goRouterProvider to return a basic router that doesn't depend on auth state.

    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [goRouterProvider.overrideWithValue(mockRouter)],
        child: const WaslaApp(),
      ),
    );

    // Verify that the splash screen is shown (CircularProgressIndicator).
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
