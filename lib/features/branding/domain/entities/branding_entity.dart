import 'package:flutter/material.dart';

class BrandingEntity {
  final String tenantId;
  final String restaurantName;
  final String? logoUrl;
  final int primaryColor;
  final int secondaryColor;
  final bool isPublished;

  const BrandingEntity({
    required this.tenantId,
    required this.restaurantName,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
    this.isPublished = true,
  });

  Color get primary => Color(primaryColor);
  Color get secondary => Color(secondaryColor);

  BrandingEntity copyWith({
    String? restaurantName,
    String? logoUrl,
    int? primaryColor,
    int? secondaryColor,
    bool? isPublished,
  }) {
    return BrandingEntity(
      tenantId: tenantId,
      restaurantName: restaurantName ?? this.restaurantName,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
