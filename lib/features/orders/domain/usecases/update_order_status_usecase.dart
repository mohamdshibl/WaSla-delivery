import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class UpdateOrderStatusUseCase {
  final OrdersRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String status,
  }) {
    return repository.updateOrderStatus(orderId: orderId, status: status);
  }
}
