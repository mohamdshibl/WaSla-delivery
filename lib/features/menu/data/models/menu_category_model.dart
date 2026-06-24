import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/menu_category_entity.dart';

class MenuCategoryModel extends MenuCategoryEntity {
  const MenuCategoryModel({
    required super.id,
    required super.tenantId,
    required super.name,
    super.description,
    super.isActive,
    super.sortOrder,
  });

  factory MenuCategoryModel.fromDoc(DocumentSnapshot doc, String tenantId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MenuCategoryModel(
      id: doc.id,
      tenantId: tenantId,
      name: data['name'] as String? ?? 'Category',
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
