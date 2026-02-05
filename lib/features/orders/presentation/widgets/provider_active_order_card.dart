import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_provider.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/wasla_button.dart';
import '../../../../core/widgets/wasla_glass_card.dart';

class ProviderActiveOrderCard extends ConsumerStatefulWidget {
  final OrderEntity order;

  const ProviderActiveOrderCard({super.key, required this.order});

  @override
  ConsumerState<ProviderActiveOrderCard> createState() =>
      _ProviderActiveOrderCardState();
}

class _ProviderActiveOrderCardState
    extends ConsumerState<ProviderActiveOrderCard> {
  bool _isLoadingStatus = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    // Status color mapping
    Color statusColor;
    String statusText;
    switch (widget.order.status) {
      case 'accepted':
        statusColor = theme.colorScheme.primary;
        statusText = l10n.statusAccepted;
        break;
      case 'picked_up':
        statusColor = Colors.cyan;
        statusText = l10n.statusPickedUp;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = l10n.statusDelivered;
        break;
      default:
        statusColor = Colors.blueGrey;
        statusText = l10n.statusUnknown;
    }

    return WaslaGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.orderIdLabel(
                  widget.order.id.substring(0, 6).toUpperCase(),
                ),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final customerAsync = ref.watch(
                    userByIdProvider(widget.order.customerId),
                  );
                  return customerAsync.when(
                    data: (customer) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                          customer?.name ?? l10n.loading,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (e, s) => Text(l10n.errorLoadingName),
                  );
                },
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
          const SizedBox(height: 16),
          Text(
            widget.order.description,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM dd, hh:mm a').format(widget.order.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/chat/${widget.order.id}'),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: Text(l10n.chat),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (widget.order.status == 'accepted')
                Expanded(
                  child: WaslaButton(
                    label: l10n.pickUp,
                    isLoading: _isLoadingStatus,
                    onPressed: () => _updateStatus(ref, context, 'picked_up'),
                  ),
                )
              else if (widget.order.status == 'picked_up')
                Expanded(
                  child: WaslaButton(
                    label: l10n.deliver,
                    isLoading: _isLoadingStatus,
                    color: Colors.green,
                    onPressed: () => _updateStatus(ref, context, 'delivered'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    WidgetRef ref,
    BuildContext context,
    String newStatus,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoadingStatus = true);
    try {
      await ref
          .read(updateOrderStatusUseCaseProvider)
          .call(orderId: widget.order.id, status: newStatus);
      if (mounted) {
        SnackbarUtils.showSuccess(context, message: l10n.statusUpdated);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: l10n.failedToUpdateStatus(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }
}
