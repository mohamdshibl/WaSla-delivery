import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String customerId;
  final String description;
  final List<String> imageUrls;
  final String
  status; // 'pending', 'accepted', 'picked_up', 'delivered', 'cancelled'
  final String? providerId;
  final double? price;
  final double? deliveryFee;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.customerId,
    required this.description,
    this.imageUrls = const [],
    this.status = 'pending',
    this.providerId,
    this.price,
    this.deliveryFee,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerId,
    description,
    imageUrls,
    status,
    providerId,
    price,
    deliveryFee,
    createdAt,
  ];
}
