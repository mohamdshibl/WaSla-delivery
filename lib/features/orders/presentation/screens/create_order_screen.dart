import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import '../providers/order_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/wasla_button.dart';
import '../../../../core/widgets/wasla_glass_card.dart';
import '../../../../core/widgets/wasla_text_field.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _descriptionController = TextEditingController();
  final List<File> _selectedImages = [];
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      SnackbarUtils.showError(context, message: l10n.pleaseEnterWhatYouNeed);
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    final createOrderUseCase = ref.read(createOrderUseCaseProvider);
    final result = await createOrderUseCase(
      customerId: user.id,
      description: description,
      images: _selectedImages,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        SnackbarUtils.showError(context, message: failure.message);
      },
      (order) {
        SnackbarUtils.showSuccess(
          context,
          message: l10n.orderCreatedSuccessfully,
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(l10n.newDelivery),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.whatCanWeGetYou,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  WaslaGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WaslaTextField(
                          controller: _descriptionController,
                          label: l10n.itemDescription,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.supportingPhotos,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ImageSourceButton(
                        icon: Icons.camera_alt_rounded,
                        label: l10n.camera,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 12),
                      _ImageSourceButton(
                        icon: Icons.photo_library_rounded,
                        label: l10n.gallery,
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _selectedImages[index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _selectedImages.removeAt(index),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 48),
                  WaslaButton(
                    label: 'Post My Order',
                    isLoading: _isLoading,
                    onPressed: _submitOrder,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            color: theme.colorScheme.primary.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
