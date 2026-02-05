import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';

class GetDeliveredOrdersUseCase {
  final OrdersRepository repository;

  GetDeliveredOrdersUseCase(this.repository);

  Stream<Either<Failure, List<OrderEntity>>> call(String providerId) {
    return repository.getDeliveredOrders(providerId);
  }
}
