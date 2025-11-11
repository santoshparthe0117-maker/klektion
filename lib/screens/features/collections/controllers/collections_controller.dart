import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_model.dart';

class CollectionController extends GetxController {
  final supabase = Supabase.instance.client;
  final RxList<CollectionModel> collections = <CollectionModel>[].obs;
  final RxList<CollectionModel> recentCollections = <CollectionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingRecent = false.obs;

  Future<void> getCollections() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

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

  Future<void> getRecentCollectionsWithItemCount() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

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
          .order('created_at', ascending: false)
          .limit(3);

      recentCollections.value = (response as List)
          .map((e) => CollectionModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Get collections error: $e");
    } finally {
      isLoadingRecent.value = false;
    }
  }

  // /// Get all images for current user
  // Future<List<Map<String, dynamic>>> getCollectionImage(String collectionId) async {
  //   try {
  //     final userId = supabase.auth.currentUser?.id;
  //     if (userId == null) return [];

  //     final response = await supabase
  //         .from(AppConstants.collectionImagesBucket)
  //         .select('*')
  //     .eq('user_id', userId)
  //     // .order('uploaded_at', ascending: false);

  //     return List<Map<String, dynamic>>.from(response);
  //   } catch (e) {
  //     print('Error fetching user images: $e');
  //     return [];
  //   }
  // }

  Future<bool> addCollection({
    required String name,
    required String description,
    required String privacy,
    String? coverImageUrl,
  }) async {
    try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'user_id': userId,
        'name': name,
        'description': description,
        'privacy': privacy,
        'cover_image_url': coverImageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      final inserted = await supabase
          .from('collections')
          .insert(data)
          .select()
          .single();

      final String collectionId = inserted['collection_id'];

      if (coverImageUrl != null) {
        await supabase.from('collection_images').insert({
          'collection_id': collectionId,
          'image_url': coverImageUrl,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await getCollections(); // refresh list
      return true;
    } catch (e) {
      print("Add collection error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
