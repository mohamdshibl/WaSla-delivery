import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String role; // 'customer' or 'provider'

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.role = 'customer',
  });

  @override
  List<Object?> get props => [id, email, name, role];
}
