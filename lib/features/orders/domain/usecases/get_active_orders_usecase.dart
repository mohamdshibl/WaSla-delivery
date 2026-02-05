import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetActiveOrdersUseCase {
  final OrdersRepository repository;

  GetActiveOrdersUseCase(this.repository);

  Stream<Either<Failure, List<OrderEntity>>> call(String providerId) {
    return repository.getActiveOrders(providerId);
  }
}
