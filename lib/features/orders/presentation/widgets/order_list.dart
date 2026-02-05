import 'package:flutter/material.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_entity.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/wasla_glass_card.dart';

class OrderList extends ConsumerWidget {
  final List<OrderEntity> orders;
  final bool shrinkWrap;

  const OrderList({super.key, required this.orders, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      if (shrinkWrap) return const SizedBox.shrink();
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(customerOrdersProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No active orders',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final listView = ListView.separated(
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          OrderListItem(key: ValueKey(orders[index].id), order: orders[index]),
    );

    if (shrinkWrap) return listView;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(customerOrdersProvider);
      },
      child: listView,
    );
  }
}

class OrderListItem extends StatelessWidget {
  final OrderEntity order;

  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Premium status color mapping
    Color statusColor;
    String statusText;
    switch (order.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = l10n.statusPending;
        break;
      case 'accepted':
        statusColor = theme.colorScheme.primary;
        statusText = l10n.statusAccepted;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = l10n.statusDelivered;
        break;
      default:
        statusColor = Colors.blueGrey;
        statusText = l10n.statusUnknown;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: WaslaGlassCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => GoRouter.of(context).push('/order/${order.id}'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (order.providerId != null)
                  Consumer(
                    builder: (context, ref, child) {
                      final providerAsync = ref.watch(
                        userByIdProvider(order.providerId!),
                      );
                      return providerAsync.when(
                        data: (provider) => Text(
                          l10n.deliveredBy(provider?.name ?? l10n.provider),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (order.imageUrls.isNotEmpty)
                            SizedBox(
                              height: 64,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: order.imageUrls.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      order.imageUrls[index],
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
