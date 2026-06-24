import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<MenuCategoryEntity>>> watchCategories(
    String tenantId,
  ) {
    return remoteDataSource.watchCategories(tenantId).map((categories) {
      return Right<Failure, List<MenuCategoryEntity>>(categories);
    }).handleError((error) {
      return Left(ServerFailure(error.toString()));
    });
  }

  @override
  Stream<Either<Failure, List<MenuItemEntity>>> watchItems(
    String tenantId, {
    String? categoryId,
  }) {
    return remoteDataSource
        .watchItems(tenantId, categoryId: categoryId)
        .map((items) {
      return Right<Failure, List<MenuItemEntity>>(items);
    }).handleError((error) {
      return Left(ServerFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, void>> upsertCategory(
    MenuCategoryEntity category,
  ) async {
    try {
      await remoteDataSource.upsertCategory(category);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(
    MenuCategoryEntity category,
  ) async {
    try {
      await remoteDataSource.deleteCategory(category);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertItem(MenuItemEntity item) async {
    try {
      await remoteDataSource.upsertItem(item);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(MenuItemEntity item) async {
    try {
      await remoteDataSource.deleteItem(item);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
