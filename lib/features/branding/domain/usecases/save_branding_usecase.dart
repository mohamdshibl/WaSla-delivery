import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/branding_entity.dart';
import '../repositories/branding_repository.dart';

class SaveBrandingUseCase {
  final BrandingRepository repository;
  SaveBrandingUseCase(this.repository);

  Future<Either<Failure, void>> call(BrandingEntity branding) {
    return repository.saveBranding(branding);
  }
}
