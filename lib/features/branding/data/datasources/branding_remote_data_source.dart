import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/branding_entity.dart';
import '../models/branding_model.dart';

abstract class BrandingRemoteDataSource {
  Stream<BrandingEntity?> watchBranding(String tenantId);
  Future<void> saveBranding(BrandingEntity branding);
  Future<String> uploadLogo({
    required String tenantId,
    required Uint8List bytes,
    required String fileName,
  });
}

class BrandingRemoteDataSourceImpl implements BrandingRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  BrandingRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Stream<BrandingEntity?> watchBranding(String tenantId) {
    return firestore
        .collection('restaurants')
        .doc(tenantId)
        .collection('config')
        .doc('branding')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return BrandingModel.fromJson({
        ...data,
        'tenantId': tenantId,
      });
    });
  }

  @override
  Future<void> saveBranding(BrandingEntity branding) async {
    final doc = firestore
        .collection('restaurants')
        .doc(branding.tenantId)
        .collection('config')
        .doc('branding');
    await doc.set(
      BrandingModel(
        tenantId: branding.tenantId,
        restaurantName: branding.restaurantName,
        logoUrl: branding.logoUrl,
        primaryColor: branding.primaryColor,
        secondaryColor: branding.secondaryColor,
        isPublished: branding.isPublished,
      ).toJson(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<String> uploadLogo({
    required String tenantId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ref = storage.ref(
      'restaurants/$tenantId/branding/logo_$fileName',
    );
    final metadata = SettableMetadata(contentType: 'image/png');
    final task = await ref.putData(bytes, metadata);
    return task.ref.getDownloadURL();
  }
}
