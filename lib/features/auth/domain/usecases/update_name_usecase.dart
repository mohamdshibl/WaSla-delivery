import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class UpdateNameUseCase {
  final AuthRepository repository;

  UpdateNameUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String name) {
    return repository.updateName(userId, name);
  }
}
