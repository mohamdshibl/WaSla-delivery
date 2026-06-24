import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/branding/presentation/providers/branding_provider.dart';
import 'wasla_logo.dart';

class BrandLogo extends ConsumerWidget {
  final double size;
  final bool showText;
  final Color? color;

  const BrandLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingStreamProvider).asData?.value;
    final theme = Theme.of(context);
    final logoColor = color ?? theme.colorScheme.primary;

    if (branding?.logoUrl != null && branding!.logoUrl!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 4),
            child: Image.network(
              branding.logoUrl!,
              width: size * 2,
              height: size * 2,
              fit: BoxFit.contain,
            ),
          ),
          if (showText)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                branding.restaurantName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: logoColor,
                ),
              ),
            ),
        ],
      );
    }

    return WaslaLogo(
      fontSize: size,
      color: logoColor,
      showText: showText,
    );
  }
}
