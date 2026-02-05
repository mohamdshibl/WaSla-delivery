import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class CreateOrderUseCase {
  final OrdersRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required String customerId,
    required String description,
    required List<File> images,
    double? price,
    double? deliveryFee,
  }) {
    return repository.createOrder(
      customerId: customerId,
      description: description,
      images: images,
      price: price,
      deliveryFee: deliveryFee,
    );
  }
}
