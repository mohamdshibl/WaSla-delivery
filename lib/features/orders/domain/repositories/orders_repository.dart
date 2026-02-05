import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    required String customerId,
    required String description,
    required List<File> images,
    double? price,
    double? deliveryFee,
  });

  Stream<Either<Failure, List<OrderEntity>>> getCustomerOrders(
    String customerId,
  );

  Stream<Either<Failure, List<OrderEntity>>> getAvailableOrders();

  Stream<Either<Failure, List<OrderEntity>>> getActiveOrders(String providerId);
  Stream<Either<Failure, List<OrderEntity>>> getDeliveredOrders(
    String providerId,
  );
  Future<Either<Failure, void>> acceptOrder({
    required String orderId,
    required String providerId,
  });

  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String status,
  });

  Stream<Either<Failure, OrderEntity>> getOrderById(String orderId);
}
