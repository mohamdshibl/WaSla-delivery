import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String role; // 'customer' or 'provider'
  final double? averageRating; // Provider's average star rating (1-5)
  final int totalRatings; // Number of ratings received

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.role = 'customer',
    this.averageRating,
    this.totalRatings = 0,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    averageRating,
    totalRatings,
  ];
}
