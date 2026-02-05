import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import '../providers/order_provider.dart';
import '../../../../core/widgets/wasla_glass_card.dart';
import '../../../../core/widgets/wasla_button.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return Center(child: Text(l10n.orderNotFound));
          }

          return CustomScrollView(
            slivers: [
              // Premium App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: order.imageUrls.isNotEmpty
                      ? Image.network(order.imageUrls.first, fit: BoxFit.cover)
                      : Container(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.delivery_dining_rounded,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26),
                  onPressed: () => context.pop(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.orderIdLabel(
                                  order.id.substring(0, 8).toUpperCase(),
                                ),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'MMMM dd, yyyy • hh:mm a',
                                ).format(order.createdAt),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          _StatusBadge(status: order.status),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Description
                      Text(
                        l10n.orderDetails,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      WaslaGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          order.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Financial Summary
                      Text(
                        l10n.totalPrice,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      WaslaGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _PriceRow(
                              label: l10n.price,
                              value: order.price ?? 0.0,
                              currency: l10n.currency,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            _PriceRow(
                              label: l10n.deliveryFee,
                              value: order.deliveryFee ?? 0.0,
                              currency: l10n.currency,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, thickness: 1.5),
                            ),
                            _PriceRow(
                              label: l10n.totalPrice,
                              value:
                                  (order.price ?? 0.0) +
                                  (order.deliveryFee ?? 0.0),
                              currency: l10n.currency,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Status Timeline
                      Text(
                        l10n.trackOrder,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _StatusTimeline(currentStatus: order.status),

                      const SizedBox(height: 40),

                      // Chat Button
                      WaslaButton(
                        label: order.providerId != null
                            ? l10n.chatWithProvider
                            : l10n.chatWithSupport,
                        icon: Icons.chat_bubble_rounded,
                        onPressed: () => context.push('/chat/${order.id}'),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text(l10n.anErrorOccurred(e.toString()))),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String statusText;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        statusText = l10n.statusPending;
        break;
      case 'accepted':
        color = Colors.blue;
        statusText = l10n.statusAccepted;
        break;
      case 'picked_up':
        color = Colors.cyan;
        statusText = l10n.statusPickedUp;
        break;
      case 'delivered':
        color = Colors.green;
        statusText = l10n.statusDelivered;
        break;
      default:
        color = Colors.grey;
        statusText = l10n.statusUnknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String currentStatus;
  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stages = ['pending', 'accepted', 'picked_up', 'delivered'];
    final currentIndex = stages.indexOf(currentStatus);

    return Column(
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == stages.length - 1;
        final stage = stages[index];

        String stageText;
        switch (stage) {
          case 'pending':
            stageText = l10n.statusPending;
            break;
          case 'accepted':
            stageText = l10n.statusAccepted;
            break;
          case 'picked_up':
            stageText = l10n.statusPickedUp;
            break;
          case 'delivered':
            stageText = l10n.statusDelivered;
            break;
          default:
            stageText = stage.replaceAll('_', ' ').toUpperCase();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stageText,
                    style: TextStyle(
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  if (isCompleted && stage == currentStatus)
                    Text(
                      l10n.updatedJustNow,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final String currency;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.currency,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} $currency',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: isTotal
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
