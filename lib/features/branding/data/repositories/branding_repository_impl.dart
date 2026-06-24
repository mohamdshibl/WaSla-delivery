import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/branding_entity.dart';
import '../../domain/repositories/branding_repository.dart';
import '../datasources/branding_remote_data_source.dart';

class BrandingRepositoryImpl implements BrandingRepository {
  final BrandingRemoteDataSource remoteDataSource;

  BrandingRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, BrandingEntity?>> watchBranding(String tenantId) {
    return remoteDataSource.watchBranding(tenantId).map((branding) {
      return Right<Failure, BrandingEntity?>(branding);
    }).handleError((error) {
      return Left<Failure, BrandingEntity?>(
        ServerFailure(error.toString()),
      );
    });
  }

  @override
  Future<Either<Failure, void>> saveBranding(BrandingEntity branding) async {
    try {
      await remoteDataSource.saveBranding(branding);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadLogo({
    required String tenantId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final url = await remoteDataSource.uploadLogo(
        tenantId: tenantId,
        bytes: bytes,
        fileName: fileName,
      );
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
