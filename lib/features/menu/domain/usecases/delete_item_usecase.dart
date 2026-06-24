import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class DeleteItemUseCase {
  final MenuRepository repository;
  DeleteItemUseCase(this.repository);

  Future<Either<Failure, void>> call(MenuItemEntity item) {
    return repository.deleteItem(item);
  }
}
