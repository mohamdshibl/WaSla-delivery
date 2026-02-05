import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/update_name_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/models/user_model.dart';

// --- Dependencies ---
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

// --- UseCases ---
final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final updateNameUseCaseProvider = Provider((ref) {
  return UpdateNameUseCase(ref.read(authRepositoryProvider));
});

// --- State ---
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateChangesProvider).asData?.value;
});

final userByIdProvider = FutureProvider.family<UserEntity?, String>((
  ref,
  userId,
) async {
  final firestore = ref.read(firestoreProvider);
  final doc = await firestore.collection('users').doc(userId).get();
  if (!doc.exists) return null;

  return UserModel.fromDocument(doc);
});

// --- Theme Settings ---
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setTheme(ThemeMode mode) => state = mode;
} // --- Localization Settings ---

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) => state = locale;
}
