import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  Stream<List<MenuCategoryEntity>> watchCategories(String tenantId);
  Stream<List<MenuItemEntity>> watchItems(
    String tenantId, {
    String? categoryId,
  });
  Future<void> upsertCategory(MenuCategoryEntity category);
  Future<void> deleteCategory(MenuCategoryEntity category);
  Future<void> upsertItem(MenuItemEntity item);
  Future<void> deleteItem(MenuItemEntity item);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final FirebaseFirestore firestore;

  MenuRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _categoriesRef(String tenantId) {
    return firestore
        .collection('restaurants')
        .doc(tenantId)
        .collection('categories');
  }

  CollectionReference<Map<String, dynamic>> _itemsRef(String tenantId) {
    return firestore
        .collection('restaurants')
        .doc(tenantId)
        .collection('menu_items');
  }

  @override
  Stream<List<MenuCategoryEntity>> watchCategories(String tenantId) {
    return _categoriesRef(tenantId)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuCategoryModel.fromDoc(doc, tenantId))
          .toList();
    });
  }

  @override
  Stream<List<MenuItemEntity>> watchItems(
    String tenantId, {
    String? categoryId,
  }) {
    Query<Map<String, dynamic>> query = _itemsRef(tenantId);
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromDoc(doc, tenantId))
          .toList();
    });
  }

  @override
  Future<void> upsertCategory(MenuCategoryEntity category) async {
    final doc = _categoriesRef(category.tenantId).doc(category.id);
    await doc.set(
      MenuCategoryModel(
        id: category.id,
        tenantId: category.tenantId,
        name: category.name,
        description: category.description,
        isActive: category.isActive,
        sortOrder: category.sortOrder,
      ).toJson(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deleteCategory(MenuCategoryEntity category) async {
    final doc = _categoriesRef(category.tenantId).doc(category.id);
    await doc.delete();
  }

  @override
  Future<void> upsertItem(MenuItemEntity item) async {
    final doc = _itemsRef(item.tenantId).doc(item.id);
    await doc.set(
      MenuItemModel(
        id: item.id,
        tenantId: item.tenantId,
        categoryId: item.categoryId,
        name: item.name,
        description: item.description,
        price: item.price,
        imageUrl: item.imageUrl,
        isAvailable: item.isAvailable,
        isFeatured: item.isFeatured,
      ).toJson(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deleteItem(MenuItemEntity item) async {
    final doc = _itemsRef(item.tenantId).doc(item.id);
    await doc.delete();
  }
}
