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

  int wishlistCount;
  bool isWishlisted;

  int commentCount;

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

    this.wishlistCount = 0,
    this.isWishlisted = false,

    this.commentCount = 0,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    List safeList(dynamic data) {
      if (data is List) return data;
      return [];
    }

    // ---------- LIKES ----------
    final likesList = safeList(json['likes']);
    int likeCount = likesList.isNotEmpty ? (likesList.first['count'] ?? 0) : 0;

    final likedByList = safeList(json['liked_by']);
    bool isLiked = likedByList.any((e) => e?['user_id'] == currentUserId);

    // ---------- WISHLIST ----------
    final wishlistList = safeList(json['wishlist']);
    int wishlistCount = wishlistList.isNotEmpty
        ? (wishlistList.first['count'] ?? 0)
        : 0;

    final wishlistedByList = safeList(json['wishlisted_by']);
    bool isWishlisted = wishlistedByList.any(
      (e) => e?['user_id'] == currentUserId,
    );

    // ---------- COMMENTS ----------
    final commentsList = safeList(json['comments']);
    int commentCount = commentsList.isNotEmpty
        ? (commentsList.first['count'] ?? 0)
        : 0;

    // ---------- IMAGES ----------
    final imageList = safeList(json['item_images']);
    final images = imageList
        .map((img) => img?['image_url'])
        .whereType<String>()
        .toList();

    // ---------- FINAL RETURN ----------
    return ItemModel(
      itemId: json['item_id'] ?? "",
      collectionId: json['collection_id'] ?? "",
      categoryId: json['category_id'],
      name: json['name'] ?? "",
      description: json['description'],
      purchasePrice: (json['purchase_price'] is num)
          ? (json['purchase_price'] as num).toDouble()
          : double.tryParse(json['purchase_price']?.toString() ?? ""),
      estimatedValue: (json['estimated_value'] is num)
          ? (json['estimated_value'] as num).toDouble()
          : double.tryParse(json['estimated_value']?.toString() ?? ""),
      acquisitionDate: json['acquisition_date'] != null
          ? DateTime.tryParse(json['acquisition_date'])
          : null,
      condition: json['condition'],
      visibility: json['visibility'] ?? "private",
      isDeleted: json['is_deleted'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? "") ?? DateTime.now(),

      images: images,

      likeCount: likeCount,
      isLiked: isLiked,

      wishlistCount: wishlistCount,
      isWishlisted: isWishlisted,

      commentCount: commentCount,
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
