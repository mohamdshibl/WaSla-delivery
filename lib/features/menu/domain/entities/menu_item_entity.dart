class MenuItemEntity {
  final String id;
  final String tenantId;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final bool isFeatured;

  const MenuItemEntity({
    required this.id,
    required this.tenantId,
    required this.categoryId,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.isFeatured = false,
  });

  MenuItemEntity copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    bool? isFeatured,
    String? categoryId,
  }) {
    return MenuItemEntity(
      id: id,
      tenantId: tenantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
