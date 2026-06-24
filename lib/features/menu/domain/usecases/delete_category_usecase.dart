import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_category_entity.dart';
import '../repositories/menu_repository.dart';

class DeleteCategoryUseCase {
  final MenuRepository repository;
  DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(MenuCategoryEntity category) {
    return repository.deleteCategory(category);
  }
}
