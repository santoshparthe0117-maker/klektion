import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../items/models/items_model.dart';

class WishlistController extends GetxController {
  final supabase = Supabase.instance.client;

  RxList<ItemModel> wishlistItems = <ItemModel>[].obs;
  RxList<ItemModel> recentWishliItems = <ItemModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingRecent = false.obs;

  /// ✅ Fetch wishlist items for logged-in user
  Future<void> fetchWishlistItems() async {
    try {
      isLoading.value = true;

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('wishlist')
          .select('''
          item:items(
            *,
            item_images(image_url),
            likes(count),
            liked_by:likes(user_id),
            wishlist(count),
            wishlisted_by:wishlist(user_id)
          )
        ''')
          .eq('user_id', userId)
          .eq('items.is_deleted', false); // 🔥 added filter here

      wishlistItems.value = response
          .map<ItemModel>((e) => ItemModel.fromJson(e['item']))
          .toList();
    } catch (e) {
      print("fetchWishlistItems error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Add item to wishlist
  Future<bool> addToWishlist(String itemId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase.from('wishlist').insert({
        'item_id': itemId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      await fetchWishlistItems();
      return true;
    } catch (e) {
      print("addToWishlist error: $e");
      return false;
    }
  }

  /// ✅ Remove item from wishlist
  Future<bool> removeFromWishlist(String itemId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // ✅ Remove from Supabase
      await supabase
          .from('wishlist')
          .delete()
          .eq('item_id', itemId)
          .eq('user_id', userId);

      // ✅ Remove from full wishlist list
      wishlistItems.removeWhere((i) => i.itemId == itemId);

      // ✅ Remove from recent wishlist items list
      recentWishliItems.removeWhere((i) => i.itemId == itemId);

      return true;
    } catch (e) {
      print("removeFromWishlist error: $e");
      return false;
    }
  }

  /// ✅ Toggle wishlist state (add/remove)
  // Future<void> toggleWishlist(ItemModel item) async {
  //   if (item.isWishlisted) {
  //     await removeFromWishlist(item.itemId);
  //   } else {
  //     await addToWishlist(item.itemId);
  //   }
  // }

  Future<void> fetchRecentItems() async {
    try {
      isLoadingRecent.value = true;

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('wishlist')
          .select('''
            item:items(
              *,
              item_images(image_url),
              likes(count),
              liked_by:likes(user_id),
              wishlist(count),
              wishlisted_by:wishlist(user_id)
            )
        ''')
          .eq('user_id', userId);

      // ✅ Convert to ItemModel list
      final items = response
          .map<ItemModel>((e) => ItemModel.fromJson(e['item']))
          .toList();

      // ✅ Limit to max 3 (safe, no error if less than 3)
      recentWishliItems.value = items.take(3).toList();
    } catch (e) {
      print("fetchRecentItems error: $e");
    } finally {
      isLoadingRecent.value = false;
    }
  }
}
