import '../../domain/entities/branding_entity.dart';

class BrandingModel extends BrandingEntity {
  const BrandingModel({
    required super.tenantId,
    required super.restaurantName,
    required super.primaryColor,
    required super.secondaryColor,
    super.logoUrl,
    super.isPublished,
  });

  factory BrandingModel.fromJson(Map<String, dynamic> json) {
    return BrandingModel(
      tenantId: json['tenantId'] as String,
      restaurantName: json['restaurantName'] as String? ?? 'Restaurant',
      logoUrl: json['logoUrl'] as String?,
      primaryColor: (json['primaryColor'] as num?)?.toInt() ?? 0xFF6366F1,
      secondaryColor: (json['secondaryColor'] as num?)?.toInt() ?? 0xFF22D3EE,
      isPublished: json['isPublished'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'restaurantName': restaurantName,
      'logoUrl': logoUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'isPublished': isPublished,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
