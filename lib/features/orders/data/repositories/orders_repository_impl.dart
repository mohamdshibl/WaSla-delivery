import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required String customerId,
    required String description,
    required List<File> images,
    double? price,
    double? deliveryFee,
  }) async {
    try {
      final order = await remoteDataSource.createOrder(
        customerId: customerId,
        description: description,
        images: images,
        price: price,
        deliveryFee: deliveryFee,
      );
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<OrderEntity>>> getCustomerOrders(
    String customerId,
  ) {
    return remoteDataSource
        .getCustomerOrders(customerId)
        .map((models) {
          return Right<Failure, List<OrderEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<OrderEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Stream<Either<Failure, List<OrderEntity>>> getAvailableOrders() {
    return remoteDataSource
        .getAvailableOrders()
        .map((models) {
          return Right<Failure, List<OrderEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<OrderEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Stream<Either<Failure, List<OrderEntity>>> getActiveOrders(
    String providerId,
  ) {
    return remoteDataSource
        .getActiveOrders(providerId)
        .map((models) {
          return Right<Failure, List<OrderEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<OrderEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Stream<Either<Failure, List<OrderEntity>>> getDeliveredOrders(
    String providerId,
  ) {
    return remoteDataSource
        .getDeliveredOrders(providerId)
        .map((models) {
          return Right<Failure, List<OrderEntity>>(models);
        })
        .handleError((error) {
          return Left<Failure, List<OrderEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Future<Either<Failure, void>> acceptOrder({
    required String orderId,
    required String providerId,
  }) async {
    try {
      await remoteDataSource.acceptOrder(
        orderId: orderId,
        providerId: providerId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, OrderEntity>> getOrderById(String orderId) {
    return remoteDataSource
        .getOrderById(orderId)
        .map((model) {
          return Right<Failure, OrderEntity>(model);
        })
        .handleError((error) {
          return Left<Failure, OrderEntity>(ServerFailure(error.toString()));
        });
  }
}
