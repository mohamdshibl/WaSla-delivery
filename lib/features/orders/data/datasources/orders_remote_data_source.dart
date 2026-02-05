import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrderModel> createOrder({
    required String customerId,
    required String description,
    required List<File> images,
    double? price,
    double? deliveryFee,
  });

  Stream<List<OrderModel>> getCustomerOrders(String customerId);

  Stream<List<OrderModel>> getAvailableOrders();

  Stream<List<OrderModel>> getActiveOrders(String providerId);
  Stream<List<OrderModel>> getDeliveredOrders(String providerId);

  Future<void> acceptOrder({
    required String orderId,
    required String providerId,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  });

  Stream<OrderModel> getOrderById(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Uuid uuid;

  OrdersRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    this.uuid = const Uuid(),
  });

  @override
  Future<OrderModel> createOrder({
    required String customerId,
    required String description,
    required List<File> images,
    double? price,
    double? deliveryFee,
  }) async {
    // 1. Upload images
    List<String> imageUrls = [];
    for (var image in images) {
      final String imageId = uuid.v4();
      final ref = storage.ref().child('orders/$customerId/$imageId.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }

    // 2. Create Order Document
    final docRef = firestore.collection('orders').doc();
    final order = OrderModel(
      id: docRef.id,
      customerId: customerId,
      description: description,
      imageUrls: imageUrls,
      status: 'pending',
      price: price,
      deliveryFee: deliveryFee,
      createdAt: DateTime.now(),
    );

    await docRef.set(order.toDocument());
    return order;
  }

  @override
  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    print("Watching customer orders for: $customerId");
    return firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print("Customer orders update: ${snapshot.docs.length} orders found");
          return snapshot.docs
              .map((doc) => OrderModel.fromDocument(doc))
              .toList();
        });
  }

  @override
  Stream<List<OrderModel>> getAvailableOrders() {
    print("Watching available orders feed...");
    return firestore
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print(
            "Available orders update: ${snapshot.docs.length} orders found",
          );
          return snapshot.docs
              .map((doc) => OrderModel.fromDocument(doc))
              .toList();
        });
  }

  @override
  Stream<List<OrderModel>> getActiveOrders(String providerId) {
    print("Watching active orders for provider: $providerId");
    return firestore
        .collection('orders')
        .where('providerId', isEqualTo: providerId)
        .where('status', whereIn: ['accepted', 'picked_up'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print("Active orders update: ${snapshot.docs.length} orders found");
          return snapshot.docs
              .map((doc) => OrderModel.fromDocument(doc))
              .toList();
        });
  }

  @override
  Stream<List<OrderModel>> getDeliveredOrders(String providerId) {
    print("Watching delivered orders for provider: $providerId");
    return firestore
        .collection('orders')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'delivered')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print(
            "Delivered orders update: ${snapshot.docs.length} orders found",
          );
          return snapshot.docs
              .map((doc) => OrderModel.fromDocument(doc))
              .toList();
        });
  }

  @override
  Future<void> acceptOrder({
    required String orderId,
    required String providerId,
  }) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': 'accepted',
      'providerId': providerId,
    });
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
  }

  @override
  Stream<OrderModel> getOrderById(String orderId) {
    return firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Order not found');
      }
      return OrderModel.fromDocument(doc);
    });
  }
}
