class CategoryModel {
  final String productCategoryId;
  final String vendorId;
  final String categoryName;
  final String? categoryDescription;
  final String categoryImagePath;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.productCategoryId,
    required this.vendorId,
    required this.categoryName,
    this.categoryDescription,
    required this.categoryImagePath,
    this.isActive = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'product_category_id': productCategoryId,
    'vendor_id': vendorId,
    'category_name': categoryName,
    'category_description': categoryDescription,
    'category_image_path': categoryImagePath,
    'is_active': isActive,
    'is_deleted': isDeleted,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class CategoryModelForPost {
  final String vendorId;
  final String categoryName;
  final String? categoryDescription;
  final String categoryImagePath;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModelForPost({
    required this.vendorId,
    required this.categoryName,
    this.categoryDescription,
    required this.categoryImagePath,
    this.isActive = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'vendor_id': vendorId,
    'category_name': categoryName,
    'category_description': categoryDescription,
    'category_image_path': categoryImagePath,
    'is_active': isActive,
    'is_deleted': isDeleted,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
