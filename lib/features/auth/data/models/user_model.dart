import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.role,
    super.averageRating,
    super.totalRatings,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      role: data['role'] ?? 'customer',
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      totalRatings: (data['totalRatings'] as int?) ?? 0,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      averageRating: entity.averageRating,
      totalRatings: entity.totalRatings,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }
}
