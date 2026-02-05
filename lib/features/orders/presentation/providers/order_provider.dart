import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/orders_remote_data_source.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_customer_orders_usecase.dart';
import '../../domain/usecases/get_available_orders_usecase.dart';
import '../../domain/usecases/accept_order_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_active_orders_usecase.dart';
import '../../domain/usecases/get_delivered_orders_usecase.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

// --- Dependencies ---
final firebaseStorageProvider = Provider((ref) => FirebaseStorage.instance);
final uuidProvider = Provider((ref) => const Uuid());

final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
    storage: ref.read(firebaseStorageProvider),
    uuid: ref.read(uuidProvider),
  );
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(ref.read(ordersRemoteDataSourceProvider));
});

// --- UseCases ---
final createOrderUseCaseProvider = Provider((ref) {
  return CreateOrderUseCase(ref.read(ordersRepositoryProvider));
});

final getCustomerOrdersUseCaseProvider = Provider((ref) {
  return GetCustomerOrdersUseCase(ref.read(ordersRepositoryProvider));
});

final getAvailableOrdersUseCaseProvider = Provider((ref) {
  return GetAvailableOrdersUseCase(ref.read(ordersRepositoryProvider));
});

final acceptOrderUseCaseProvider = Provider((ref) {
  return AcceptOrderUseCase(ref.read(ordersRepositoryProvider));
});

final updateOrderStatusUseCaseProvider = Provider((ref) {
  return UpdateOrderStatusUseCase(ref.read(ordersRepositoryProvider));
});

final getOrderByIdUseCaseProvider = Provider((ref) {
  return GetOrderByIdUseCase(ref.read(ordersRepositoryProvider));
});

final getActiveOrdersUseCaseProvider = Provider((ref) {
  return GetActiveOrdersUseCase(ref.read(ordersRepositoryProvider));
});

final getDeliveredOrdersUseCaseProvider = Provider((ref) {
  return GetDeliveredOrdersUseCase(ref.read(ordersRepositoryProvider));
});

// --- State ---
final customerOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  final getCustomerOrders = ref.read(getCustomerOrdersUseCaseProvider);

  return getCustomerOrders(user.id).map((event) {
    return event.fold((failure) => throw failure, (orders) => orders);
  });
});

final availableOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != 'provider') return const Stream.empty();

  final getAvailableOrders = ref.read(getAvailableOrdersUseCaseProvider);

  return getAvailableOrders().map((event) {
    return event.fold((failure) => throw failure, (orders) => orders);
  });
});

final activeOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != 'provider') return const Stream.empty();

  final getActiveOrders = ref.read(getActiveOrdersUseCaseProvider);

  return getActiveOrders(user.id).map((event) {
    return event.fold((failure) => throw failure, (orders) => orders);
  });
});

final deliveredOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != 'provider') return const Stream.empty();

  final getDeliveredOrders = ref.read(getDeliveredOrdersUseCaseProvider);

  return getDeliveredOrders(user.id).map((event) {
    return event.fold((failure) => throw failure, (orders) => orders);
  });
});

final orderDetailsProvider = StreamProvider.family<OrderEntity?, String>((
  ref,
  orderId,
) {
  final getOrderById = ref.read(getOrderByIdUseCaseProvider);
  return getOrderById(orderId).map((event) {
    return event.fold((failure) => throw failure, (r) => r);
  });
});
