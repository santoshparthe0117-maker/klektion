import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import 'items_controller.dart';

class CommentController extends GetxController {
  final supabase = Supabase.instance.client;

  /// STATE
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isAdding = false.obs;
  RxBool isDeleting = false.obs;

  /// Needed to update commentCount on item
  final ItemController itemController = Get.find<ItemController>();

  /// Fetch all comments for selected item
  Future<void> fetchComments(String itemId) async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('comments')
          .select('''
      comment_id,
      user_id,
      item_id,
      comment,
      created_at,
      is_deleted,
      user:users(name, avatar_url)
    ''')
          .eq('item_id', itemId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      comments.value = (response as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      print("❌ fetchComments error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Add comment to item
  Future<bool> addComment(String itemId, String text) async {
    try {
      isAdding.value = true;

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final newEntry = {
        'user_id': userId,
        'item_id': itemId,
        'comment': text.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
      };

      final inserted = await supabase
          .from('comments')
          .insert(newEntry)
          .select()
          .single();

      /// Add comment locally so UI updates instantly
      comments.insert(0, CommentModel.fromJson(inserted));

      /// Update comment count in selected item
      itemController.selectedItem.update((item) {
        if (item != null) {
          item.commentCount = (item.commentCount ?? 0) + 1;
        }
      });

      return true;
    } catch (e) {
      print("❌ addComment error: $e");
      return false;
    } finally {
      isAdding.value = false;
    }
  }

  /// Delete comment (soft delete)
  Future<bool> deleteComment(String commentId) async {
    try {
      isDeleting.value = true;

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      /// Soft delete
      await supabase
          .from('comments')
          .update({'is_deleted': true})
          .eq('comment_id', commentId)
          .eq('user_id', userId);

      /// Remove from local list
      comments.removeWhere((c) => c.commentId == commentId);

      /// Decrease comment count
      itemController.selectedItem.update((item) {
        if (item != null && item.commentCount != null) {
          item.commentCount = item.commentCount! > 0
              ? item.commentCount! - 1
              : 0;
        }
      });

      return true;
    } catch (e) {
      print("❌ deleteComment error: $e");
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
