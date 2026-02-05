import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/wasla_button.dart';
import '../../../../core/widgets/wasla_glass_card.dart';

class ProviderOrderList extends ConsumerWidget {
  final List<OrderEntity> orders;
  final bool shrinkWrap;

  const ProviderOrderList({
    super.key,
    required this.orders,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (orders.isEmpty) {
      if (shrinkWrap) return const SizedBox.shrink();
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableOrdersProvider);
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
                      Icons.auto_awesome_outlined,
                      size: 64,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noOrdersFound,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final list = ListView.separated(
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _ProviderOrderItem(key: ValueKey(order.id), order: order);
      },
    );

    if (shrinkWrap) return list;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(availableOrdersProvider);
      },
      child: list,
    );
  }
}

class _ProviderOrderItem extends StatefulWidget {
  final OrderEntity order;
  const _ProviderOrderItem({super.key, required this.order});

  @override
  State<_ProviderOrderItem> createState() => _ProviderOrderItemState();
}

class _ProviderOrderItemState extends State<_ProviderOrderItem> {
  bool _isAccepting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => context.push('/order/${widget.order.id}'),
      borderRadius: BorderRadius.circular(24),
      child: WaslaGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final customerAsync = ref.watch(
                      userByIdProvider(widget.order.customerId),
                    );
                    return customerAsync.when(
                      data: (customer) => Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.customerLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              customer?.name ?? l10n.unknownCustomer,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      loading: () =>
                          const Expanded(child: LinearProgressIndicator()),
                      error: (e, s) =>
                          Expanded(child: Text(l10n.errorLoadingName)),
                    );
                  },
                ),
                _StatusBadge(status: widget.order.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.order.description,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('MMM dd, hh:mm a').format(widget.order.createdAt),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            if (widget.order.status == 'pending') ...[
              const SizedBox(height: 20),
              Consumer(
                builder: (context, ref, child) {
                  return WaslaButton(
                    label: l10n.acceptOrder,
                    isLoading: _isAccepting,
                    onPressed: () async {
                      final user = ref.read(currentUserProvider);
                      if (user == null) return;

                      setState(() => _isAccepting = true);
                      try {
                        await ref
                            .read(acceptOrderUseCaseProvider)
                            .call(
                              orderId: widget.order.id,
                              providerId: user.id,
                            );
                        if (mounted) {
                          SnackbarUtils.showSuccess(
                            context,
                            message: l10n.orderAccepted,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isAccepting = false);
                          SnackbarUtils.showError(
                            context,
                            message: l10n.failedToAccept(e.toString()),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String statusText;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        statusText = l10n.statusPending;
        break;
      case 'accepted':
        color = theme.colorScheme.primary;
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
        color = Colors.blueGrey;
        statusText = l10n.statusUnknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
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
