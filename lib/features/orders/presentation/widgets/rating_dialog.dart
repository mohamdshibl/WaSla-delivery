import 'package:flutter/material.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';

class RatingDialog extends StatefulWidget {
  final String orderId;
  final String providerId;
  final Function(int rating, String? review) onSubmit;

  const RatingDialog({
    super.key,
    required this.orderId,
    required this.providerId,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.rateProvider,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: AnimatedScale(
                    scale: _selectedRating >= starIndex ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _selectedRating >= starIndex
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 40,
                      color: _selectedRating >= starIndex
                          ? Colors.amber
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Review Text Field
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.writeReview,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedRating == 0 || _isSubmitting
                    ? null
                    : () async {
                        setState(() => _isSubmitting = true);
                        await widget.onSubmit(
                          _selectedRating,
                          _reviewController.text.isNotEmpty
                              ? _reviewController.text
                              : null,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.submitRating),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
