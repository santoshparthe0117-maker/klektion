import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/items_model.dart';

class ItemController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  RxList<ItemModel> itemList = <ItemModel>[].obs;
  RxList<ItemModel> itemListByCollection = <ItemModel>[].obs;
  RxList<ItemModel> recentItemList = <ItemModel>[].obs;
  RxList<ItemModel> filteredItems = <ItemModel>[].obs;
  final Rxn<ItemModel> selectedItem = Rxn<ItemModel>();

  RxBool isLoadingByCategory = false.obs;
  RxList<ItemModel> itemsByCategory = <ItemModel>[].obs;

  var isLoading = false.obs;
  var isLoadingByCollection = false.obs;

  var isRecentLoading = false.obs;
  var isLoadingItemDetails = false.obs;
  var categories = [].obs;
  var subCategories = [].obs;
  var selectedCategory;
  var selectedSubCategory;
  var imageFiles = <Uint8List>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   getItemsByUser();
  //   fetchCategories();
  // }

  void fetchCategories() async {
    try {
      isLoading.value = true;
      final vendorId = supabase.auth.currentUser?.id ?? '';

      // Fetch categories from Supabase
      final response = await supabase
          .from('product_categories')
          .select()
          .eq('vendor_id', vendorId) // filter by current vendor/user
          .eq('is_deleted', false) // optional: only active categories
          .order('created_at', ascending: true);

      if (response != null && response.isNotEmpty) {
        // Map the Supabase data to your CategoryModel
        categories.value = response;
      } else {
        categories.clear(); // No categories found for this user
      }
    } catch (e) {
      print('Error fetching categories: $e');
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getItemsByCategory(String categoryId) async {
    try {
      isLoadingByCategory.value = true;

      final response = await supabase
          .from('items')
          .select('''
            *,
            item_images(image_url),
            likes(count),
            liked_by:likes(user_id),
            wishlist(count),
            wishlisted_by:wishlist(user_id)
          ''')
          .eq('category_id', categoryId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final data = response as List;

      itemsByCategory.value = data.map((e) => ItemModel.fromJson(e)).toList();
    } catch (e) {
      print("getItemsByCategory error: $e");
    } finally {
      isLoadingByCategory.value = false;
    }
  }

  Future<void> getItemsByCollection(String collectionId) async {
    try {
      isLoadingByCollection.value = true;

      final response = await supabase
          .from('items')
          .select('*, item_images(image_url)')
          .eq('collection_id', collectionId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      itemListByCollection.value = data
          .map((e) => ItemModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching items for collection: $e");
    } finally {
      isLoadingByCollection.value = false;
    }
  }

  Future<void> getItemDetails(String itemId) async {
    try {
      isLoadingItemDetails.value = true;

      final response = await supabase
          .from('items')
          .select('''
      *,
      item_images(image_url),

      likes(count),
      liked_by:likes(user_id),

      wishlist(count),
      wishlisted_by:wishlist(user_id),

      comments:comments!inner(count)
    ''')
          .eq('item_id', itemId)
          .eq('comments.is_deleted', false) // ✅ Count only non-deleted comments
          .maybeSingle();

      if (response != null) {
        selectedItem.value = ItemModel.fromJson(response);
      }
    } catch (e) {
      print("Error fetching item details: $e");
    } finally {
      isLoadingItemDetails.value = false;
    }
  }

  Future<void> toggleLike(String itemId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final existing = await supabase
          .from('likes')
          .select()
          .eq('item_id', itemId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // ✅ Unlike
        await supabase
            .from('likes')
            .delete()
            .eq('item_id', existing['item_id']);

        selectedItem.update((item) {
          if (item != null) {
            item.isLiked = false;
            item.likeCount = item.likeCount - 1;
          }
        });
      } else {
        // ✅ Like
        await supabase.from('likes').insert({
          'item_id': itemId,
          'user_id': userId,
        });

        selectedItem.update((item) {
          if (item != null) {
            item.isLiked = true;
            item.likeCount = item.likeCount + 1;
          }
        });
      }
    } catch (e) {
      print("Toggle like error: $e");
    }
  }

  Future<void> toggleWishlist(String itemId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 🔍 Check if already in wishlist
      final existing = await supabase
          .from('wishlist')
          .select()
          .eq('item_id', itemId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // ✅ Remove from wishlist
        await supabase
            .from('wishlist')
            .delete()
            .eq('wishlist_id', existing['wishlist_id']);

        selectedItem.update((item) {
          if (item != null) {
            item.isWishlisted = false;
          }
        });
        Get.snackbar(
          "Removed",
          "Item removed from wishlist",
          colorText: Colors.white,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      } else {
        // ✅ Add to wishlist
        await supabase.from('wishlist').insert({
          'item_id': itemId,
          'user_id': userId,
        });

        selectedItem.update((item) {
          if (item != null) {
            item.isWishlisted = true;
          }
        });
        Get.snackbar(
          "Added",
          "Item added to wishlist",
          colorText: Colors.white,
          backgroundColor: Colors.green.withOpacity(0.8),
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print("Toggle wishlist error: $e");
    }
  }

  Future<void> getItemsByUser() async {
    try {
      isLoading.value = true;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print("⚠️ No logged-in user");
        return;
      }

      final response = await supabase
          .from('items')
          .select('*, item_images(image_url)')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      itemList.value = data.map((e) => ItemModel.fromJson(e)).toList();
      filteredItems.value = [...itemList]; // copy list
    } catch (e) {
      print('❌ Error fetching items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItems.value = [...itemList];
      return;
    }

    final lowerQuery = query.toLowerCase();

    filteredItems.value = itemList.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          (item.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<void> getRecentItems() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    try {
      isRecentLoading.value = true;

      if (userId == null) {
        print("⚠️ No logged-in user");
        return;
      }

      final response = await supabase
          .from('items')
          .select('*, item_images(image_url)')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(3);

      final data = response as List<dynamic>;

      recentItemList.value = data.map((e) => ItemModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error fetching recent items: $e');
    } finally {
      isRecentLoading.value = false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // 🔥 Soft delete item
      await supabase
          .from('items')
          .update({'is_deleted': true})
          .eq('item_id', itemId)
          .eq('user_id', userId);

      // 🔥 Remove from main list
      itemList.removeWhere((i) => i.itemId == itemId);

      // 🔥 Remove from filtered list (search results)
      filteredItems.removeWhere((i) => i.itemId == itemId);

      // 🔥 Remove from recent list
      // recentItemList.removeWhere((i) => i.itemId == itemId);

      return true;
    } catch (e) {
      print("❌ deleteItem error: $e");
      return false;
    }
  }

  /// Save image record to database
  Future<void> _saveImageRecord(String imageUrl, String itemId) async {
    try {
      await supabase.from('item_images').insert({
        'item_id': itemId,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving image record: $e');
    }
  }

  Future<bool> addItem({
    required String name,
    required String collectionId,
    required String? categoryId,
    required double? purchasePrice,
    required double? estimatedValue,
    required String shortDesciption,
    required String description,
    required String visibility, // private / public
    DateTime? acquisitionDate,
    String? condition,
    required List<String> imageUrls,
  }) async {
    try {
      isLoading.value = true;

      // ✅ Get current logged-in user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print("⚠️ User not logged in");
        return false;
      }

      final itemData = {
        'user_id': userId, // ✅ added here
        'collection_id': collectionId,
        'category_id': categoryId,
        'name': name,
        'short_description': shortDesciption,
        'description': description,
        'purchase_price': purchasePrice,
        'estimated_value': estimatedValue,
        'acquisition_date': acquisitionDate?.toIso8601String(),
        'condition': condition,
        'visibility': visibility,
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // ✅ Insert & get returned row
      final inserted = await supabase
          .from('items')
          .insert(itemData)
          .select()
          .single();

      final String itemId = inserted['item_id'];

      // ✅ Upload images and insert into item_images table
      for (var imageUrl in imageUrls) {
        _saveImageRecord(imageUrl, itemId);
      }

      return true;
    } catch (e) {
      print("Add item error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateItem({
    required String itemId,
    required String name,
    required String collectionId,
    required String? categoryId,
    required double? purchasePrice,
    required double? estimatedValue,
    required String description,
    required String visibility,
    DateTime? acquisitionDate,
    String? condition,
    required List<String> imageUrls, // final updated list
  }) async {
    try {
      isLoading.value = true;

      // ✅ Validate user
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print("⚠️ User not logged in");
        return false;
      }

      // ✅ Data to update
      final itemData = {
        'collection_id': collectionId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'purchase_price': purchasePrice,
        'estimated_value': estimatedValue,
        'acquisition_date': acquisitionDate?.toIso8601String(),
        'condition': condition,
        'visibility': visibility,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // ✅ Update main item row
      await supabase.from('items').update(itemData).eq('item_id', itemId);

      // ✅ Remove old image records (but do NOT delete from storage)
      await supabase.from('item_images').delete().eq('item_id', itemId);

      // ✅ Add new image records
      for (var imageUrl in imageUrls) {
        await _saveImageRecord(imageUrl, itemId);
      }

      return true;
    } catch (e) {
      print("Update item error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
