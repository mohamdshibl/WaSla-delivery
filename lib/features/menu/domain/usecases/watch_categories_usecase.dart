import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_category_entity.dart';
import '../repositories/menu_repository.dart';

class WatchCategoriesUseCase {
  final MenuRepository repository;
  WatchCategoriesUseCase(this.repository);

  Stream<Either<Failure, List<MenuCategoryEntity>>> call(String tenantId) {
    return repository.watchCategories(tenantId);
  }
}
