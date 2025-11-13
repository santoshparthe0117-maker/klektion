import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileStatsController extends GetxController {
  final supabase = Supabase.instance.client;

  RxInt totalItems = 0.obs;
  RxInt totalFollowers = 0.obs;
  RxInt totalFollowing = 0.obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileStats();
  }

  /// ----------------------------------------------------------------------
  /// Fetch ALL stats for logged-in user → items / followers / following
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

      // =========== 2️⃣ TOTAL FOLLOWERS ===========
      final followersRes = await supabase
          .from('follows')
          .select('follower_id')
          .eq('following_id', userId);

      totalFollowers.value = followersRes.length;

      // =========== 3️⃣ TOTAL FOLLOWING ===========
      final followingRes = await supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId);

      totalFollowing.value = followingRes.length;
    } catch (e) {
      print("fetchProfileStats error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------------------------
  /// Recalculate Follower Count when Follow/Unfollow happens
  /// Call this from FollowController.toggleFollow()
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
