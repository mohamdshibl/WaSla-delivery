import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/branding_remote_data_source.dart';
import '../../data/repositories/branding_repository_impl.dart';
import '../../domain/entities/branding_entity.dart';
import '../../domain/repositories/branding_repository.dart';
import '../../domain/usecases/save_branding_usecase.dart';
import '../../domain/usecases/upload_logo_usecase.dart';
import '../../domain/usecases/watch_branding_usecase.dart';

final brandingRemoteDataSourceProvider = Provider<BrandingRemoteDataSource>(
  (ref) => BrandingRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
    storage: FirebaseStorage.instance,
  ),
);

final brandingRepositoryProvider = Provider<BrandingRepository>((ref) {
  return BrandingRepositoryImpl(ref.read(brandingRemoteDataSourceProvider));
});

final watchBrandingUseCaseProvider = Provider((ref) {
  return WatchBrandingUseCase(ref.read(brandingRepositoryProvider));
});

final saveBrandingUseCaseProvider = Provider((ref) {
  return SaveBrandingUseCase(ref.read(brandingRepositoryProvider));
});

final uploadLogoUseCaseProvider = Provider((ref) {
  return UploadLogoUseCase(ref.read(brandingRepositoryProvider));
});

final brandingStreamProvider = StreamProvider<BrandingEntity?>((ref) {
  final watchBranding = ref.read(watchBrandingUseCaseProvider);
  return watchBranding(AppConfig.tenantId).map((event) {
    return event.fold((failure) => throw failure, (branding) => branding);
  });
});

final lightThemeProvider = Provider<ThemeData>((ref) {
  final branding = ref.watch(brandingStreamProvider).asData?.value;
  return AppTheme.lightTheme(
    primary: branding?.primary,
    secondary: branding?.secondary,
  );
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final branding = ref.watch(brandingStreamProvider).asData?.value;
  return AppTheme.darkTheme(
    primary: branding?.primary,
    secondary: branding?.secondary,
  );
});
