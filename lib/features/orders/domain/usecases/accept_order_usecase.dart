import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class AcceptOrderUseCase {
  final OrdersRepository repository;

  AcceptOrderUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String providerId,
  }) {
    return repository.acceptOrder(orderId: orderId, providerId: providerId);
  }
}
