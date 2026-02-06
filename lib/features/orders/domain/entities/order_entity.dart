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
  final int? rating; // 1-5 star rating from customer
  final String? review; // Optional text review
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
    this.rating,
    this.review,
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
    rating,
    review,
    createdAt,
  ];
}
