import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../orders/presentation/widgets/order_list.dart';
import '../../../orders/presentation/widgets/provider_order_list.dart';
import '../../../orders/presentation/widgets/provider_active_order_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          l10n.appTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(logoutUseCaseProvider).call(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: authState.value?.role == 'customer'
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-order'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              label: Text(
                l10n.newOrder,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add_rounded),
            )
          : null,
      body: authState.when(
        data: (user) {
          if (user == null) return Center(child: Text(l10n.notLoggedIn));

          final isProvider = user.role == 'provider';
          final ordersAsync = isProvider
              ? ref.watch(availableOrdersProvider)
              : ref.watch(customerOrdersProvider);

          final activeOrdersAsync = isProvider
              ? ref.watch(activeOrdersProvider)
              : const AsyncValue<List<OrderEntity>>.data([]);

          final deliveredOrdersAsync = isProvider
              ? ref.watch(deliveredOrdersProvider)
              : const AsyncValue<List<OrderEntity>>.data([]);

          return Stack(
            children: [
              // Subtle background decoration
              Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondary.withOpacity(0.03),
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 60),
                  // User Welcome Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isProvider ? l10n.waslaVendor : l10n.waslaHome,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                l10n.welcomeBackUser(user.name ?? l10n.friend),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.push('/profile'),
                          icon: const Icon(Icons.person_outline_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        if (isProvider) ...[
                          // Active Orders Section
                          activeOrdersAsync.when(
                            data: (activeOrders) => activeOrders.isEmpty
                                ? const SliverToBoxAdapter(
                                    child: SizedBox.shrink(),
                                  )
                                : SliverToBoxAdapter(
                                    child: _SectionHeader(
                                      title: l10n.myActiveOrders,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                            loading: () => const SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, s) => SliverToBoxAdapter(
                              child: Center(
                                child: Text(l10n.anErrorOccurred(e.toString())),
                              ),
                            ),
                          ),
                          activeOrdersAsync.when(
                            data: (activeOrders) => SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  child: ProviderActiveOrderCard(
                                    order: activeOrders[index],
                                  ),
                                ),
                                childCount: activeOrders.length,
                              ),
                            ),
                            loading: () => const SliverToBoxAdapter(),
                            error: (e, s) => const SliverToBoxAdapter(),
                          ),

                          // Available Orders Section
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(indent: 24, endIndent: 24),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _SectionHeader(
                              title: l10n.availableForDelivery,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          ordersAsync.when(
                            data: (orders) => orders.isEmpty
                                ? SliverToBoxAdapter(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Text(l10n.noNewOrdersAvailable),
                                      ),
                                    ),
                                  )
                                : SliverToBoxAdapter(
                                    child: ProviderOrderList(
                                      orders: (orders as List)
                                          .cast<OrderEntity>(),
                                      shrinkWrap: true,
                                    ),
                                  ),
                            loading: () => const SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, s) => SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  l10n.errorLoadingOrders(e.toString()),
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Delivered Orders Section
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(indent: 24, endIndent: 24),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _SectionHeader(
                              title: l10n.orderHistory,
                              color: Colors.green,
                            ),
                          ),
                          deliveredOrdersAsync.when(
                            data: (List<OrderEntity> orders) => orders.isEmpty
                                ? SliverToBoxAdapter(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Text(l10n.noDeliveredOrders),
                                      ),
                                    ),
                                  )
                                : SliverToBoxAdapter(
                                    child: ProviderOrderList(
                                      orders: orders,
                                      shrinkWrap: true,
                                    ),
                                  ),
                            loading: () => const SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, s) => SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  l10n.errorLoadingHistory(e.toString()),
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Customer Orders
                          SliverToBoxAdapter(
                            child: _SectionHeader(
                              title: l10n.myOrders,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          ordersAsync.when(
                            data: (List<OrderEntity> orders) => orders.isEmpty
                                ? SliverToBoxAdapter(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Text(l10n.noOrdersYet),
                                      ),
                                    ),
                                  )
                                : SliverToBoxAdapter(
                                    child: OrderList(
                                      orders: orders,
                                      shrinkWrap: true,
                                    ),
                                  ),
                            loading: () => const SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, s) => SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  l10n.errorLoadingOrders(e.toString()),
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 80),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.anErrorOccurred(err.toString()))),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
