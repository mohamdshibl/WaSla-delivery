import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetCustomerOrdersUseCase {
  final OrdersRepository repository;

  GetCustomerOrdersUseCase(this.repository);

  Stream<Either<Failure, List<OrderEntity>>> call(String customerId) {
    return repository.getCustomerOrders(customerId);
  }
}
