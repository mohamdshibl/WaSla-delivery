import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/branding_entity.dart';

abstract class BrandingRepository {
  Stream<Either<Failure, BrandingEntity?>> watchBranding(String tenantId);
  Future<Either<Failure, void>> saveBranding(BrandingEntity branding);
  Future<Either<Failure, String>> uploadLogo({
    required String tenantId,
    required Uint8List bytes,
    required String fileName,
  });
}
