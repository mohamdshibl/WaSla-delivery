import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.tenantId,
    required super.categoryId,
    required super.name,
    required super.price,
    super.description,
    super.imageUrl,
    super.isAvailable,
    super.isFeatured,
  });

  factory MenuItemModel.fromDoc(DocumentSnapshot doc, String tenantId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MenuItemModel(
      id: doc.id,
      tenantId: tenantId,
      categoryId: data['categoryId'] as String? ?? '',
      name: data['name'] as String? ?? 'Item',
      description: data['description'] as String?,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String?,
      isAvailable: data['isAvailable'] as bool? ?? true,
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
