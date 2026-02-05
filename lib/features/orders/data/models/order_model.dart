import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.customerId,
    required super.description,
    super.imageUrls,
    super.status,
    super.providerId,
    required super.createdAt,
  });

  factory OrderModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: data['status'] ?? 'pending',
      providerId: data['providerId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'customerId': customerId,
      'description': description,
      'imageUrls': imageUrls,
      'status': status,
      'providerId': providerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
