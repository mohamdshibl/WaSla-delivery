import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderByIdUseCase {
  final OrdersRepository repository;

  GetOrderByIdUseCase(this.repository);

  Stream<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}
