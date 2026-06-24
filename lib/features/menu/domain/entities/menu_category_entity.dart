class MenuCategoryEntity {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final bool isActive;
  final int sortOrder;

  const MenuCategoryEntity({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
  });

  MenuCategoryEntity copyWith({
    String? name,
    String? description,
    bool? isActive,
    int? sortOrder,
  }) {
    return MenuCategoryEntity(
      id: id,
      tenantId: tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
