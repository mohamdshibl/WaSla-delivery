import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/branding_repository.dart';

class UploadLogoUseCase {
  final BrandingRepository repository;
  UploadLogoUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String tenantId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return repository.uploadLogo(
      tenantId: tenantId,
      bytes: bytes,
      fileName: fileName,
    );
  }
}
