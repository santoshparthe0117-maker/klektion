import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowController extends GetxController {
  final supabase = Supabase.instance.client;

  // Stores follow state: {"userId": true/false}
  RxMap<String, bool> isFollowingMap = <String, bool>{}.obs;

  // Stores follower count if needed
  RxMap<String, int> followerCountMap = <String, int>{}.obs;

  /// ----------------------------------------------------
  /// Load follow status for a list of users (bulk fetch)
  /// ----------------------------------------------------
  Future<void> loadFollowStatus(List<dynamic> users) async {
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return;

    for (var u in users) {
      final targetUserId = u['user_id'];
      if (targetUserId == null) continue;

      final existing = await supabase
          .from('follows')
          .select()
          .eq('follower_id', myId)
          .eq('following_id', targetUserId)
          .maybeSingle();

      isFollowingMap[targetUserId] = existing != null;
    }
  }

  /// ----------------------------------------------------
  /// Toggle Follow / Unfollow
  /// ----------------------------------------------------
  Future<void> toggleFollow(String targetUserId) async {
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return;

    final isCurrentlyFollowing = isFollowingMap[targetUserId] ?? false;

    if (isCurrentlyFollowing) {
      // 🔻 UNFOLLOW
      isFollowingMap[targetUserId] = false; // UI immediate update

      await supabase
          .from('follows')
          .delete()
          .eq('follower_id', myId)
          .eq('following_id', targetUserId);
    } else {
      // 🔺 FOLLOW
      isFollowingMap[targetUserId] = true;

      await supabase.from('follows').insert({
        'follower_id': myId,
        'following_id': targetUserId,
      });
    }
  }
}
