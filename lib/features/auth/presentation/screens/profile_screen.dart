import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasla/l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/wasla_button.dart';
import '../../../../core/widgets/wasla_glass_card.dart';
import '../../../../core/widgets/wasla_logo.dart';
import '../../../../core/utils/snackbar_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      SnackbarUtils.showError(context, message: l10n.nameCannotBeEmpty);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await ref
          .read(updateNameUseCaseProvider)
          .call(user.id, _nameController.text.trim());

      result.fold(
        (failure) => SnackbarUtils.showError(context, message: failure.message),
        (_) {
          setState(() => _isEditing = false);
          SnackbarUtils.showSuccess(context, message: l10n.profileUpdated);
        },
      );
    } catch (e) {
      SnackbarUtils.showError(
        context,
        message: l10n.anErrorOccurred(e.toString()),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.myProfile),
        actions: [
          if (_isEditing)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              onPressed: _isSaving ? null : _saveName,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar / Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: WaslaLogo(
                  fontSize: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.enterYourName,
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                ),
              )
            else
              Text(
                user?.name ?? l10n.user,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            _RoleBadge(role: user?.role ?? 'customer'),

            const SizedBox(height: 48),

            // Profile info cards
            WaslaGlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _ProfileInfoRow(
                    icon: Icons.person_outline_rounded,
                    label: l10n.displayName,
                    value: user?.name ?? 'N/A',
                  ),
                  const Divider(height: 32),
                  _ProfileInfoRow(
                    icon: Icons.email_outlined,
                    label: l10n.email,
                    value: user?.email ?? 'N/A',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings card
            WaslaGlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.darkMode),
                    subtitle: Text(
                      themeMode == ThemeMode.dark
                          ? l10n.enabled
                          : l10n.disabled,
                      style: const TextStyle(fontSize: 12),
                    ),
                    secondary: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setTheme(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  SwitchListTile(
                    title: Text(l10n.language),
                    subtitle: Text(
                      locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
                      style: const TextStyle(fontSize: 12),
                    ),
                    secondary: Icon(
                      Icons.translate_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    value: locale.languageCode == 'ar',
                    onChanged: (val) {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(val ? 'ar' : 'en'));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Logout Button
            WaslaButton(
              label: l10n.logout,
              icon: Icons.logout_rounded,
              color: Colors.redAccent,
              onPressed: () => ref.read(logoutUseCaseProvider).call(),
            ),

            const SizedBox(height: 40),
            Text(
              'Wasla v1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
