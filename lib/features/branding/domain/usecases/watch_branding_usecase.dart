import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/branding_entity.dart';
import '../repositories/branding_repository.dart';

class WatchBrandingUseCase {
  final BrandingRepository repository;
  WatchBrandingUseCase(this.repository);

  Stream<Either<Failure, BrandingEntity?>> call(String tenantId) {
    return repository.watchBranding(tenantId);
  }
}
