import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetAvailableOrdersUseCase {
  final OrdersRepository repository;

  GetAvailableOrdersUseCase(this.repository);

  Stream<Either<Failure, List<OrderEntity>>> call() {
    return repository.getAvailableOrders();
  }
}
