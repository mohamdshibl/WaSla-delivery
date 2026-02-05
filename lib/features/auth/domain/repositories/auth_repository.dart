import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String name,
    String role,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, void>> updateName(String userId, String name);
}
