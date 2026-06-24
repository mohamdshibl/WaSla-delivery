import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/menu_remote_data_source.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/upsert_category_usecase.dart';
import '../../domain/usecases/upsert_item_usecase.dart';
import '../../domain/usecases/watch_categories_usecase.dart';
import '../../domain/usecases/watch_items_usecase.dart';

final menuRemoteDataSourceProvider = Provider<MenuRemoteDataSource>((ref) {
  return MenuRemoteDataSourceImpl(firestore: ref.read(firestoreProvider));
});

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl(ref.read(menuRemoteDataSourceProvider));
});

final watchCategoriesUseCaseProvider = Provider((ref) {
  return WatchCategoriesUseCase(ref.read(menuRepositoryProvider));
});

final watchItemsUseCaseProvider = Provider((ref) {
  return WatchItemsUseCase(ref.read(menuRepositoryProvider));
});

final upsertCategoryUseCaseProvider = Provider((ref) {
  return UpsertCategoryUseCase(ref.read(menuRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider((ref) {
  return DeleteCategoryUseCase(ref.read(menuRepositoryProvider));
});

final upsertItemUseCaseProvider = Provider((ref) {
  return UpsertItemUseCase(ref.read(menuRepositoryProvider));
});

final deleteItemUseCaseProvider = Provider((ref) {
  return DeleteItemUseCase(ref.read(menuRepositoryProvider));
});

final menuCategoriesProvider = StreamProvider<List<MenuCategoryEntity>>((ref) {
  final watchCategories = ref.read(watchCategoriesUseCaseProvider);
  return watchCategories(AppConfig.tenantId).map((event) {
    return event.fold((failure) => throw failure, (data) => data);
  });
});

final menuItemsProvider =
    StreamProvider.family<List<MenuItemEntity>, String?>((ref, categoryId) {
  final watchItems = ref.read(watchItemsUseCaseProvider);
  return watchItems(AppConfig.tenantId, categoryId: categoryId).map((event) {
    return event.fold((failure) => throw failure, (data) => data);
  });
});
