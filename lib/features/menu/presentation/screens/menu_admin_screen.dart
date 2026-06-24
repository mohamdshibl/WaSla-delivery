import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../providers/menu_provider.dart';

class MenuAdminScreen extends ConsumerStatefulWidget {
  const MenuAdminScreen({super.key});

  @override
  ConsumerState<MenuAdminScreen> createState() => _MenuAdminScreenState();
}

class _MenuAdminScreenState extends ConsumerState<MenuAdminScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(menuCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Manager'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'category') {
                _showCategoryDialog(context);
              } else if (value == 'item') {
                _showItemDialog(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'category',
                child: Text('Add category'),
              ),
              PopupMenuItem(
                value: 'item',
                child: Text('Add menu item'),
              ),
            ],
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
          final itemsAsync = ref.watch(menuItemsProvider(_selectedCategoryId));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Categories',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _CategoryChips(
                categories: categories,
                selectedId: _selectedCategoryId,
                onSelected: (id) => setState(() => _selectedCategoryId = id),
                onEdit: (category) => _showCategoryDialog(context, category),
                onDelete: (category) => _confirmDeleteCategory(
                  context,
                  category,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Menu Items',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              itemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const _EmptyState(
                      title: 'No items yet',
                      subtitle: 'Add your first menu item.',
                    );
                  }
                  return Column(
                    children: items
                        .map(
                          (item) => _MenuItemCard(
                            item: item,
                            onEdit: () => _showItemDialog(context, item: item),
                            onDelete: () =>
                                _confirmDeleteItem(context, item),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => _EmptyState(
                  title: 'Failed to load items',
                  subtitle: error.toString(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _EmptyState(
          title: 'Failed to load categories',
          subtitle: error.toString(),
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, [
    MenuCategoryEntity? category,
  ]) async {
    final nameController = TextEditingController(text: category?.name);
    final descriptionController = TextEditingController(
      text: category?.description,
    );
    bool isActive = category?.isActive ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'Add Category' : 'Edit Category'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) {
                        setState(() => isActive = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;
    if (nameController.text.trim().isEmpty) {
      SnackbarUtils.showError(context, message: 'Name is required.');
      return;
    }

    final id = category?.id ?? const Uuid().v4();
    final payload = MenuCategoryEntity(
      id: id,
      tenantId: AppConfig.tenantId,
      name: nameController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      isActive: isActive,
      sortOrder: category?.sortOrder ?? DateTime.now().millisecondsSinceEpoch,
    );

    final resultSave =
        await ref.read(upsertCategoryUseCaseProvider).call(payload);
    resultSave.fold(
      (failure) => SnackbarUtils.showError(
        context,
        message: failure.message,
      ),
      (_) => SnackbarUtils.showSuccess(
        context,
        message: 'Category saved.',
      ),
    );
  }

  Future<void> _showItemDialog(
    BuildContext context, {
    MenuItemEntity? item,
  }) async {
    if (_selectedCategoryId == null) {
      SnackbarUtils.showInfo(
        context,
        message: 'Create a category first.',
      );
      return;
    }

    final nameController = TextEditingController(text: item?.name);
    final descriptionController = TextEditingController(
      text: item?.description,
    );
    final priceController = TextEditingController(
      text: item != null ? item.price.toStringAsFixed(2) : '',
    );
    final imageController = TextEditingController(text: item?.imageUrl);
    bool isAvailable = item?.isAvailable ?? true;
    bool isFeatured = item?.isFeatured ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Available'),
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() => isAvailable = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Special offer'),
                      value: isFeatured,
                      onChanged: (value) {
                        setState(() => isFeatured = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;
    if (nameController.text.trim().isEmpty) {
      SnackbarUtils.showError(context, message: 'Name is required.');
      return;
    }
    final price = double.tryParse(priceController.text.trim());
    if (price == null) {
      SnackbarUtils.showError(context, message: 'Price is invalid.');
      return;
    }

    final id = item?.id ?? const Uuid().v4();
    final payload = MenuItemEntity(
      id: id,
      tenantId: AppConfig.tenantId,
      categoryId: _selectedCategoryId!,
      name: nameController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      price: price,
      imageUrl:
          imageController.text.trim().isEmpty ? null : imageController.text,
      isAvailable: isAvailable,
      isFeatured: isFeatured,
    );

    final resultSave =
        await ref.read(upsertItemUseCaseProvider).call(payload);
    resultSave.fold(
      (failure) => SnackbarUtils.showError(
        context,
        message: failure.message,
      ),
      (_) => SnackbarUtils.showSuccess(
        context,
        message: 'Item saved.',
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    MenuCategoryEntity category,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: const Text(
          'This will remove the category. Menu items remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final result =
        await ref.read(deleteCategoryUseCaseProvider).call(category);
    result.fold(
      (failure) => SnackbarUtils.showError(
        context,
        message: failure.message,
      ),
      (_) => SnackbarUtils.showSuccess(
        context,
        message: 'Category deleted.',
      ),
    );
  }

  Future<void> _confirmDeleteItem(
    BuildContext context,
    MenuItemEntity item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final result = await ref.read(deleteItemUseCaseProvider).call(item);
    result.fold(
      (failure) => SnackbarUtils.showError(
        context,
        message: failure.message,
      ),
      (_) => SnackbarUtils.showSuccess(
        context,
        message: 'Item deleted.',
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<MenuCategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final ValueChanged<MenuCategoryEntity> onEdit;
  final ValueChanged<MenuCategoryEntity> onDelete;

  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _EmptyState(
        title: 'No categories yet',
        subtitle: 'Add your first category.',
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = category.id == selectedId;
        return GestureDetector(
          onLongPress: () => onEdit(category),
          child: InputChip(
            label: Text(category.name),
            selected: isSelected,
            onSelected: (_) => onSelected(category.id),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () => onDelete(category),
          ),
        );
      }).toList(),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fastfood_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.description != null)
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!item.isAvailable)
                      const Chip(
                        label: Text('Unavailable'),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (item.isFeatured)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Chip(
                          label: Text('Special'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
