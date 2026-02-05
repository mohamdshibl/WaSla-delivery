import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String role,
  );
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<void> updateName(String userId, String name);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) return null;
        return UserModel.fromDocument(doc);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final result = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user == null) throw Exception('User not found');

    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) throw Exception('User data not found');

    return UserModel.fromDocument(doc);
  }

  @override
  Future<UserModel> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    final result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user == null) throw Exception('Registration failed');

    final newUser = UserModel(
      id: user.uid,
      email: email,
      name: name,
      role: role,
    );

    await firestore.collection('users').doc(user.uid).set(newUser.toDocument());
    return newUser;
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDocument(doc);
  }

  @override
  Future<void> updateName(String userId, String name) async {
    await firestore.collection('users').doc(userId).update({'name': name});
  }
}
