import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/branding_entity.dart';
import '../providers/branding_provider.dart';

class BrandingAdminScreen extends ConsumerStatefulWidget {
  const BrandingAdminScreen({super.key});

  @override
  ConsumerState<BrandingAdminScreen> createState() =>
      _BrandingAdminScreenState();
}

class _BrandingAdminScreenState extends ConsumerState<BrandingAdminScreen> {
  final _nameController = TextEditingController();
  Uint8List? _logoBytes;
  String? _logoUrl;
  Color? _primary;
  Color? _secondary;
  bool _initialized = false;
  bool _isSaving = false;
  bool _isExtracting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    setState(() => _isExtracting = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file == null) {
        setState(() => _isExtracting = false);
        return;
      }

      final bytes = await file.readAsBytes();
      final palette = await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
        size: const Size(256, 256),
        maximumColorCount: 12,
      );
      final theme = Theme.of(context);
      final primary = palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          theme.colorScheme.primary;
      final secondary = palette.lightVibrantColor?.color ??
          palette.mutedColor?.color ??
          theme.colorScheme.secondary;

      setState(() {
        _logoBytes = bytes;
        _primary = primary;
        _secondary = secondary;
        _isExtracting = false;
      });
    } catch (e) {
      setState(() => _isExtracting = false);
      SnackbarUtils.showError(context, message: 'Logo processing failed.');
    }
  }

  Future<void> _publish() async {
    if (_nameController.text.trim().isEmpty) {
      SnackbarUtils.showError(
        context,
        message: 'Restaurant name is required.',
      );
      return;
    }

    final theme = Theme.of(context);
    final primary = _primary ?? theme.colorScheme.primary;
    final secondary = _secondary ?? theme.colorScheme.secondary;

    setState(() => _isSaving = true);
    try {
      String? logoUrl = _logoUrl;
      if (_logoBytes != null) {
        final uploadResult = await ref.read(uploadLogoUseCaseProvider).call(
              tenantId: AppConfig.tenantId,
              bytes: _logoBytes!,
              fileName: DateTime.now().millisecondsSinceEpoch.toString(),
            );
        logoUrl = uploadResult.fold((failure) {
          throw failure;
        }, (url) => url);
      }

      final branding = BrandingEntity(
        tenantId: AppConfig.tenantId,
        restaurantName: _nameController.text.trim(),
        logoUrl: logoUrl,
        primaryColor: primary.value,
        secondaryColor: secondary.value,
        isPublished: true,
      );

      final result = await ref.read(saveBrandingUseCaseProvider).call(branding);
      result.fold(
        (failure) => SnackbarUtils.showError(
          context,
          message: failure.message,
        ),
        (_) => SnackbarUtils.showSuccess(
          context,
          message: 'Branding updated.',
        ),
      );
    } catch (_) {
      SnackbarUtils.showError(context, message: 'Failed to save branding.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetToSaved(BrandingEntity? branding) {
    if (branding == null) return;
    setState(() {
      _logoBytes = null;
      _logoUrl = branding.logoUrl;
      _primary = branding.primary;
      _secondary = branding.secondary;
      _nameController.text = branding.restaurantName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingStreamProvider).asData?.value;
    final theme = Theme.of(context);

    if (!_initialized && branding != null) {
      _nameController.text = branding.restaurantName;
      _logoUrl = branding.logoUrl;
      _primary = branding.primary;
      _secondary = branding.secondary;
      _initialized = true;
    }

    final effectivePrimary = _primary ?? theme.colorScheme.primary;
    final effectiveSecondary = _secondary ?? theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branding & Theme'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _resetToSaved(branding),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Restaurant Identity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Restaurant name',
            ),
          ),
          const SizedBox(height: 20),
          _LogoPickerCard(
            logoBytes: _logoBytes,
            logoUrl: _logoUrl,
            isExtracting: _isExtracting,
            onPick: _pickLogo,
          ),
          const SizedBox(height: 24),
          Text(
            'Brand Colors',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ColorSwatchRow(
            label: 'Primary',
            color: effectivePrimary,
          ),
          const SizedBox(height: 8),
          _ColorSwatchRow(
            label: 'Secondary',
            color: effectiveSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'Theme Preview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ThemePreview(
            primary: effectivePrimary,
            secondary: effectiveSecondary,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isSaving ? null : _publish,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(_isSaving ? 'Publishing...' : 'Publish Theme'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPickerCard extends StatelessWidget {
  final Uint8List? logoBytes;
  final String? logoUrl;
  final bool isExtracting;
  final VoidCallback onPick;

  const _LogoPickerCard({
    required this.logoBytes,
    required this.logoUrl,
    required this.isExtracting,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLogo = logoBytes != null || (logoUrl?.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant logo',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: hasLogo
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: logoBytes != null
                        ? Image.memory(
                            logoBytes!,
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            logoUrl!,
                            fit: BoxFit.contain,
                          ),
                  )
                : const Icon(
                    Icons.storefront_outlined,
                    size: 48,
                  ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isExtracting ? null : onPick,
            icon: isExtracting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
            label: Text(isExtracting ? 'Extracting colors...' : 'Upload logo'),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatchRow extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorSwatchRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text('#${color.value.toRadixString(16).toUpperCase()}'),
      ],
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const _ThemePreview({
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final previewTheme = AppTheme.lightTheme(
      primary: primary,
      secondary: secondary,
    );

    return Theme(
      data: previewTheme,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: previewTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: previewTheme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview card',
              style: previewTheme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: () {},
                  child: const Text('Primary'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Secondary'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Special')),
                Chip(label: Text('Available')),
                Chip(label: Text('Promo')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
