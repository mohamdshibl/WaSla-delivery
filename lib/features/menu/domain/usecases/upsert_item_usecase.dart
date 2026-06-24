import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class UpsertItemUseCase {
  final MenuRepository repository;
  UpsertItemUseCase(this.repository);

  Future<Either<Failure, void>> call(MenuItemEntity item) {
    return repository.upsertItem(item);
  }
}
