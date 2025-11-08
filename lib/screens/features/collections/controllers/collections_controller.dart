import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_model.dart';

class CollectionController extends GetxController {
  final supabase = Supabase.instance.client;
  final RxList<CollectionModel> collections = <CollectionModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> getCollections() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    try {
      isLoading.value = true;
      final response = await supabase
          .from('collections')
          .select()
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

  Future<String?> uploadImage(File file) async {
    try {
      final path = 'collections/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('collection-images').upload(path, file);
      final url = supabase.storage.from('collection-images').getPublicUrl(path);
      return url;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<bool> addCollection({
    required String name,
    required String description,
    required String privacy,
    File? coverImage,
  }) async {
    try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;

      String? imageUrl;
      if (coverImage != null) {
        imageUrl = await uploadImage(coverImage);
      }

      final data = {
        'user_id': userId,
        'name': name,
        'description': description,
        'privacy': privacy,
        'cover_image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('collections').insert(data);

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
