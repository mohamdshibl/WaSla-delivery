import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import '../providers/order_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/wasla_glass_card.dart';
import 'package:intl/intl.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    // We'll use the delivered orders to calculate earnings for now
    final deliveredOrdersAsync = ref.watch(deliveredOrdersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(l10n.wallet),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                    : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: deliveredOrdersAsync.when(
              data: (orders) {
                final totalEarnings = orders.fold<double>(
                  0,
                  (sum, order) => sum + (order.deliveryFee ?? 0.0),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Balance Card
                      WaslaGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              l10n.totalEarnings,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${totalEarnings.toStringAsFixed(2)} ${l10n.currency}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'ORDERS',
                                  value: orders.length.toString(),
                                  icon: Icons.check_circle_outline_rounded,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: theme.dividerColor,
                                ),
                                _StatItem(
                                  label: 'RANK',
                                  value: 'TOP 10%',
                                  icon: Icons.trending_up_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        l10n.orderHistory,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (orders.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              l10n.noDeliveredOrders,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return WaslaGlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order #${order.id.substring(0, 6).toUpperCase()}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'MMM dd, hh:mm a',
                                          ).format(order.createdAt),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.5),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+${(order.deliveryFee ?? 0.0).toStringAsFixed(2)} ${l10n.currency}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
