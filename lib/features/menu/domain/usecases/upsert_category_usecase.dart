import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_category_entity.dart';
import '../repositories/menu_repository.dart';

class UpsertCategoryUseCase {
  final MenuRepository repository;
  UpsertCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(MenuCategoryEntity category) {
    return repository.upsertCategory(category);
  }
}
