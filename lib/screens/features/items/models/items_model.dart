class ProductModel {
  final String productId;
  final String vendorId;
  final String productName;
  final String? productDescription;
  final double productPrice;
  final double? discountAmount;
  final double? discountedPrice;
  final int stock;
  final bool isActive;
  final bool isDeleted;
  final String productCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.productId,
    required this.vendorId,
    required this.productName,
    this.productDescription,
    required this.productPrice,
    this.discountAmount,
    this.discountedPrice,
    required this.stock,
    required this.isActive,
    required this.isDeleted,
    required this.productCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      productName: json['product_name'] ?? '',
      productDescription: json['product_description'],
      productPrice: (json['product_price'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      discountedPrice: (json['discounted_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      productCategoryId: json['product_category_id'].toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class AddProductModel {
  final String productName;
  final String categoryId;
  final String subCategoryId;
  final String brandName;
  final double mrp;
  final double sellingPrice;
  final int stockQuantity;
  final String sku;
  final String description;
  final List<String>? imageUrls;

  AddProductModel({
    required this.productName,
    required this.categoryId,
    required this.subCategoryId,
    required this.brandName,
    required this.mrp,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.sku,
    required this.description,
    this.imageUrls,
  });
}
