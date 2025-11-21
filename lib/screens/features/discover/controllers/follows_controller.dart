import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowController extends GetxController {
  final supabase = Supabase.instance.client;

  /// -----------------------------
  /// REACTIVE STATES
  /// -----------------------------
  RxBool isLoading = false.obs;

  // userId : true/false → already following?
  RxMap<String, bool> isFollowingMap = <String, bool>{}.obs;

  // userId : true → follow request already sent
  RxMap<String, bool> requestSentMap = <String, bool>{}.obs;

  // userId : true → private account
  RxMap<String, bool> isPrivateMap = <String, bool>{}.obs;

  // incoming follow requests list
  RxList<Map<String, dynamic>> incomingRequests = <Map<String, dynamic>>[].obs;

  RxList<Map<String, dynamic>> followersList = <Map<String, dynamic>>[].obs;
  RxBool isLoadingFollowers = false.obs;

  RxList<Map<String, dynamic>> followingList = <Map<String, dynamic>>[].obs;
  RxBool isLoadingFollowing = false.obs;

  /// ----------------------------------------------------
  /// LOAD FOLLOW STATE FOR USERS LIST
  /// ----------------------------------------------------
  Future<void> loadFollowState(List<dynamic> users) async {
    isLoading.value = true;

    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      for (var user in users) {
        final targetUserId = user['user_id'];
        if (targetUserId == null) continue;

        // visibility
        final visibility = user['visibility'] ?? "public";
        isPrivateMap[targetUserId] = (visibility == "private");

        // follow check
        try {
          final follow = await supabase
              .from('follows')
              .select()
              .eq('follower_id', myId)
              .eq('following_id', targetUserId)
              .maybeSingle();

          isFollowingMap[targetUserId] = follow != null;
        } catch (e) {
          print("Error checking follow: $e");
        }

        // request check
        try {
          final pending = await supabase
              .from('follow_requests')
              .select()
              .eq('sender_id', myId)
              .eq('receiver_id', targetUserId)
              .eq('status', 'pending')
              .maybeSingle();

          requestSentMap[targetUserId] = pending != null;
        } catch (e) {
          print("Error checking pending request: $e");
        }
      }
    } catch (e) {
      print("Error loadFollowState: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------
  /// MAIN BUTTON HANDLER
  /// ----------------------------------------------------
  Future<void> handleFollowTap({
    required String targetUserId,
    required String visibility,
  }) async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      final isFollowing = isFollowingMap[targetUserId] ?? false;
      final isRequested = requestSentMap[targetUserId] ?? false;
      final isPrivate = visibility == "private";

      if (isFollowing) return unfollowUser(targetUserId);
      if (isRequested) {
        Get.snackbar("Request Pending", "You already sent a follow request.");
        return;
      }
      if (isPrivate) return sendFollowRequest(targetUserId);

      return followUser(targetUserId);
    } catch (e) {
      print("Error handleFollowTap: $e");
    }
  }

  /// ----------------------------------------------------
  /// FOLLOW PUBLIC USER
  /// ----------------------------------------------------
  Future<void> followUser(String targetUserId) async {
    isLoading.value = true;

    try {
      final myId = supabase.auth.currentUser!.id;

      isFollowingMap[targetUserId] = true;

      await supabase.from('follows').insert({
        'follower_id': myId,
        'following_id': targetUserId,
      });
    } catch (e) {
      print("Error followUser: $e");
      Get.snackbar("Error", "Failed to follow user.");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------
  /// UNFOLLOW USER
  /// ----------------------------------------------------
  Future<void> unfollowUser(String targetUserId) async {
    isLoading.value = true;

    try {
      final myId = supabase.auth.currentUser!.id;

      isFollowingMap[targetUserId] = false;

      await supabase
          .from('follows')
          .delete()
          .eq('follower_id', myId)
          .eq('following_id', targetUserId);
    } catch (e) {
      print("Error unfollowUser: $e");
      Get.snackbar("Error", "Failed to unfollow user.");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------
  /// SEND FOLLOW REQUEST (PRIVATE USERS)
  /// ----------------------------------------------------
  Future<void> sendFollowRequest(String targetUserId) async {
    isLoading.value = true;

    try {
      final myId = supabase.auth.currentUser!.id;

      requestSentMap[targetUserId] = true;

      await supabase.from('follow_requests').insert({
        'sender_id': myId,
        'receiver_id': targetUserId,
        'status': 'pending',
      });
    } catch (e) {
      print("Error sendFollowRequest: $e");
      Get.snackbar("Error", "Failed to send request.");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------
  /// ACCEPT REQUEST
  /// ----------------------------------------------------
  Future<void> acceptRequest(String requestId, String senderId) async {
    isLoading.value = true;

    try {
      final myId = supabase.auth.currentUser!.id;

      await supabase
          .from('follow_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);

      await supabase.from('follows').insert({
        'follower_id': senderId,
        'following_id': myId,
      });

      requestSentMap[senderId] = false;
      isFollowingMap[senderId] = true;
    } catch (e) {
      print("Error acceptRequest: $e");
      Get.snackbar("Error", "Failed to accept request.");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------
  /// FETCH INCOMING REQUESTS
  /// ----------------------------------------------------
  Future<void> fetchIncomingRequests() async {
    isLoading.value = true;

    try {
      final myId = supabase.auth.currentUser!.id;

      final data = await supabase
          .from('follow_requests')
          .select(
            'id, sender_id, users!follow_requests_sender_id_fkey1(name, avatar_url)',
          )
          .eq('receiver_id', myId)
          .eq('status', 'pending');

      incomingRequests.assignAll(data);
    } catch (e) {
      print("Error fetchIncomingRequests: $e");
      Get.snackbar("Error", "Failed to load follow requests.");
    } finally {
      isLoading.value = false;
    }
  }

  /// ----------------------------------------------------
  /// APPROVE REQUEST WRAPPER
  /// ----------------------------------------------------
  Future<void> approveRequestAction(String requestId, String senderId) async {
    await acceptRequest(requestId, senderId);
    await fetchIncomingRequests();
  }

  /// ----------------------------------------------------
  /// REJECT REQUEST WRAPPER
  /// ----------------------------------------------------
  Future<void> rejectRequestAction(String requestId) async {
    isLoading.value = true;

    try {
      await supabase
          .from('follow_requests')
          .update({'status': 'rejected'})
          .eq('id', requestId);

      await fetchIncomingRequests();
    } catch (e) {
      print("Error rejectRequestAction: $e");
      Get.snackbar("Error", "Failed to reject request.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFollowersList() async {
    try {
      isLoadingFollowers.value = true;
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      final res = await supabase
          .from('follows')
          .select(
            'follower_id, users!follows_follower_id_fkey(name, avatar_url, user_id)',
          )
          .eq('following_id', myId);

      followersList.assignAll(res);
    } catch (e) {
      print("Fetch followers error: $e");
      Get.snackbar("Error", "Unable to load followers.");
    } finally {
      isLoadingFollowers.value = false;
    }
  }

  Future<void> removeFollower(String followerId) async {
    try {
      isLoading.value = true;

      final myId = supabase.auth.currentUser!.id;

      await supabase
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', myId);

      // remove locally
      followersList.removeWhere((f) => f['users']['user_id'] == followerId);

      Get.snackbar("Removed", "User removed from your followers.");
    } catch (e) {
      print("removeFollower error: $e");
      Get.snackbar("Error", "Unable to remove follower");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFollowingList() async {
    try {
      isLoadingFollowing.value = true;

      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      final res = await supabase
          .from('follows')
          .select(
            'following_id, users!follows_following_id_fkey(name, avatar_url, user_id)',
          )
          .eq('follower_id', myId);

      followingList.assignAll(res);
    } catch (e) {
      print("fetchFollowingList error: $e");
      Get.snackbar("Error", "Unable to load following.");
    } finally {
      isLoadingFollowing.value = false;
    }
  }

  Future<void> removeFromFollowing(String followingId) async {
    try {
      isLoading.value = true;

      final myId = supabase.auth.currentUser!.id;

      await supabase
          .from('follows')
          .delete()
          .eq('follower_id', myId)
          .eq('following_id', followingId);

      followingList.removeWhere((u) => u['users']['user_id'] == followingId);

      // update state
      isFollowingMap[followingId] = false;

      Get.snackbar("Removed", "You unfollowed this user.");
    } catch (e) {
      print("removeFromFollowing error: $e");
      Get.snackbar("Error", "Failed to unfollow user");
    } finally {
      isLoading.value = false;
    }
  }
}
