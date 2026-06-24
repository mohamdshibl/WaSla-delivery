import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class WatchItemsUseCase {
  final MenuRepository repository;
  WatchItemsUseCase(this.repository);

  Stream<Either<Failure, List<MenuItemEntity>>> call(
    String tenantId, {
    String? categoryId,
  }) {
    return repository.watchItems(tenantId, categoryId: categoryId);
  }
}
