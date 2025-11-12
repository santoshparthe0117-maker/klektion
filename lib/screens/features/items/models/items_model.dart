import 'package:supabase_flutter/supabase_flutter.dart';

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

class ItemModel {
  final String itemId;
  final String collectionId;
  final String? categoryId;
  final String name;
  final String? description;
  final double? purchasePrice;
  final double? estimatedValue;
  final DateTime? acquisitionDate;
  final String? condition;
  final String visibility;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<String> images;
  int likeCount;
  bool isLiked;
  bool isWishlisted;

  ItemModel({
    required this.itemId,
    required this.collectionId,
    this.categoryId,
    required this.name,
    this.description,
    this.purchasePrice,
    this.estimatedValue,
    this.acquisitionDate,
    this.condition,
    required this.visibility,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,

    this.images = const [],
    this.likeCount = 0,
    this.isLiked = false,
    this.isWishlisted = false,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // ✅ Safe list extraction helper
    List safeList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value;
      return [];
    }

    // ✅ Likes List
    List likesList = safeList(json['likes']);
    int likeCount = 0;
    if (likesList.isNotEmpty) {
      final countValue = likesList[0]['count'];
      if (countValue is int)
        likeCount = countValue;
      else if (countValue is num)
        likeCount = countValue.toInt();
    }

    // ✅ Is Liked check (safe)
    bool isLiked = false;
    final likedList = safeList(json['liked_by']);
    if (currentUserId != null) {
      isLiked = likedList.any(
        (e) => e != null && e['user_id'] == currentUserId,
      );
    }

    // ✅ Wishlist check (safe)
    bool isWishlisted = false;
    final wishList = safeList(json['wishlisted_by']);
    if (currentUserId != null) {
      isWishlisted = wishList.any(
        (e) => e != null && e['user_id'] == currentUserId,
      );
    }

    // ✅ Images list safe
    List<String> images = [];
    final imageList = safeList(json['item_images']);
    for (var img in imageList) {
      if (img != null && img['image_url'] != null) {
        images.add(img['image_url']);
      }
    }

    return ItemModel(
      itemId: json['item_id']?.toString() ?? "",
      collectionId: json['collection_id']?.toString() ?? "",
      categoryId: json['category_id']?.toString(),
      name: json['name']?.toString() ?? "",
      description: json['description']?.toString(),
      purchasePrice: json['purchase_price'] != null
          ? (json['purchase_price'] is num
                ? (json['purchase_price'] as num).toDouble()
                : double.tryParse(json['purchase_price'].toString()))
          : null,
      estimatedValue: json['estimated_value'] != null
          ? (json['estimated_value'] is num
                ? (json['estimated_value'] as num).toDouble()
                : double.tryParse(json['estimated_value'].toString()))
          : null,
      acquisitionDate: json['acquisition_date'] != null
          ? DateTime.tryParse(json['acquisition_date'].toString())
          : null,
      condition: json['condition']?.toString(),
      visibility: json['visibility']?.toString() ?? "private",
      isDeleted: json['is_deleted'] == true,
      createdAt: DateTime.tryParse(json['created_at'] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? "") ?? DateTime.now(),
      images: images,
      likeCount: likeCount,
      isLiked: isLiked,
      isWishlisted: isWishlisted,
    );
  }

  @override
  String toString() {
    return 'ItemModel(itemId: $itemId, collectionId: $collectionId, categoryId: $categoryId, name: $name, description: $description, purchasePrice: $purchasePrice, estimatedValue: $estimatedValue, acquisitionDate: $acquisitionDate, condition: $condition, visibility: $visibility, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, images: $images)';
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

class AddItemModel {
  String itemId;
  String collectionId;
  String? categoryId;
  String name;
  String? description;
  double? purchasePrice;
  double? estimatedValue;
  String visibility; // public / private
  DateTime createdAt;

  AddItemModel({
    required this.itemId,
    required this.collectionId,
    this.categoryId,
    required this.name,
    this.description,
    this.purchasePrice,
    this.estimatedValue,
    required this.visibility,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'collection_id': collectionId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'purchase_price': purchasePrice,
      'estimated_value': estimatedValue,
      'visibility': visibility,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
