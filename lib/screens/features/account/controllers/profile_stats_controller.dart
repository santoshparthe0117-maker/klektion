import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileStatsController extends GetxController {
  final supabase = Supabase.instance.client;

  // Your existing stats
  RxInt totalItems = 0.obs;
  RxInt totalFollowers = 0.obs;
  RxInt totalFollowing = 0.obs;

  // ⭐ New Stats
  RxInt totalLikes = 0.obs;
  RxInt totalComments = 0.obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileStats();
  }

  /// ----------------------------------------------------------------------
  /// Fetch ALL stats for logged-in user → items / followers / following / likes / comments
  /// ----------------------------------------------------------------------
  Future<void> fetchProfileStats() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;

      // =========== 1️⃣ TOTAL ITEMS ================
      final itemsRes = await supabase
          .from('items')
          .select('item_id')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      totalItems.value = itemsRes.length;

      final followersRes = await supabase
          .from('follows')
          .select('follower_id')
          .eq('following_id', userId);

      totalFollowers.value = followersRes.length;

      // =========== 5️⃣ TOTAL FOLLOWING ===========

      final followingRes = await supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId);

      totalFollowing.value = followingRes.length;

      // Extract itemIds for next queries
      final List<String> myItemIds = itemsRes
          .map<String>((e) => e['item_id'] as String)
          .toList();

      // If user has no items → set 0 stats
      if (myItemIds.isEmpty) {
        totalLikes.value = 0;
        totalComments.value = 0;
      } else {
        // Convert list → SQL IN format ('a','b','c')
        final String idList = "(${myItemIds.join(',')})";

        // TOTAL LIKES
        final likesRes = await supabase
            .from('likes')
            .select('item_id')
            .filter('item_id', 'in', idList);

        totalLikes.value = likesRes.length;

        // TOTAL COMMENTS
        final commentsRes = await supabase
            .from('comments')
            .select('item_id')
            .eq('is_deleted', false)
            .filter('item_id', 'in', idList);

        totalComments.value = commentsRes.length;
      }

      // =========== 4️⃣ TOTAL FOLLOWERS ===========
    } catch (e) {
      print("fetchProfileStats error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------------------------
  /// Recalculate Follower Count when Follow/Unfollow happens
  /// ----------------------------------------------------------------------
  Future<void> refreshFollowerCounts() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final followersRes = await supabase
        .from('follows')
        .select('follower_id')
        .eq('following_id', userId);

    totalFollowers.value = followersRes.length;
  }

  /// ----------------------------------------------------------------------
  /// Recalculate Following Count (when YOU follow someone)
  /// ----------------------------------------------------------------------
  Future<void> refreshFollowingCounts() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final followingRes = await supabase
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);

    totalFollowing.value = followingRes.length;
  }
}
