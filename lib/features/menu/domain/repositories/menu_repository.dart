import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_category_entity.dart';
import '../entities/menu_item_entity.dart';

abstract class MenuRepository {
  Stream<Either<Failure, List<MenuCategoryEntity>>> watchCategories(
    String tenantId,
  );
  Stream<Either<Failure, List<MenuItemEntity>>> watchItems(
    String tenantId, {
    String? categoryId,
  });
  Future<Either<Failure, void>> upsertCategory(MenuCategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(MenuCategoryEntity category);
  Future<Either<Failure, void>> upsertItem(MenuItemEntity item);
  Future<Either<Failure, void>> deleteItem(MenuItemEntity item);
}
