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
    super.price,
    super.deliveryFee,
    super.rating,
    super.review,
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
      price: (data['price'] as num?)?.toDouble(),
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble(),
      rating: data['rating'] as int?,
      review: data['review'] as String?,
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
      'price': price,
      'deliveryFee': deliveryFee,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
