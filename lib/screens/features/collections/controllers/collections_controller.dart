import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_model.dart';

class CollectionController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<CollectionModel> collections = <CollectionModel>[].obs;
  final RxList<CollectionModel> recentCollections = <CollectionModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingRecent = false.obs;
  final RxBool isDeleting = false.obs;

  /// ------------------------------------------------------------
  /// GET ALL COLLECTIONS (only non-deleted)
  /// ------------------------------------------------------------
  Future<void> getCollections() async {
    final userId = supabase.auth.currentUser?.id ?? '';

    try {
      isLoading.value = true;

      final response = await supabase
          .from('collections')
          .select('''
            *,
            collection_images(image_url),
            items(count)
          ''')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      collections.value = (response as List)
          .map((e) => CollectionModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Get collections error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ------------------------------------------------------------
  /// GET ONLY RECENT 3 COLLECTIONS
  /// ------------------------------------------------------------
  Future<void> getRecentCollectionsWithItemCount() async {
    final userId = supabase.auth.currentUser?.id ?? '';

    try {
      isLoadingRecent.value = true;

      final response = await supabase
          .from('collections')
          .select('''
            *,
            collection_images(image_url),
            items(count)
          ''')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(3);

      recentCollections.value = (response as List)
          .map((e) => CollectionModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Get Collections Recent error: $e");
    } finally {
      isLoadingRecent.value = false;
    }
  }

  /// ------------------------------------------------------------
  /// ADD NEW COLLECTION
  /// ------------------------------------------------------------
  Future<bool> addCollection({
    required String name,
    required String description,
    required String privacy,
    String? coverImageUrl,
  }) async {
    try {
      isLoading.value = true;

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not authenticated");

      final data = {
        'user_id': userId,
        'name': name,
        'description': description,
        'privacy': privacy,
        'cover_image_url': coverImageUrl,
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final inserted = await supabase
          .from('collections')
          .insert(data)
          .select()
          .single();

      final String collectionId = inserted['collection_id'];

      // Save cover image
      if (coverImageUrl != null) {
        await supabase.from('collection_images').insert({
          'collection_id': collectionId,
          'image_url': coverImageUrl,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await getCollections(); // Refresh list
      return true;
    } catch (e) {
      print("Add Collection error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ------------------------------------------------------------
  /// DELETE COLLECTION (soft delete)
  /// ------------------------------------------------------------
  Future<bool> deleteCollection(String collectionId) async {
    try {
      isDeleting.value = true;

      // Soft delete → set is_deleted = true
      await supabase
          .from('collections')
          .update({'is_deleted': true})
          .eq('collection_id', collectionId);

      // Remove locally
      collections.removeWhere((c) => c.collectionId == collectionId);
      recentCollections.removeWhere((c) => c.collectionId == collectionId);

      return true;
    } catch (e) {
      print("Delete collection error: $e");
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
