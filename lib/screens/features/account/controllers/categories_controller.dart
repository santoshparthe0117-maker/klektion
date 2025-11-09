import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  final supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;

  Future<void> fetchCategories() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 0;
    try {
      isLoading.value = true;

      final response = await supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      categories.value = response
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Fetch category error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCategory({required String name, String? description}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    try {
      final data = {
        "user_id": userId,
        "name": name,
        "description": description,
      };

      final inserted = await supabase
          .from('categories')
          .insert(data)
          .select()
          .single();

      categories.insert(0, CategoryModel.fromJson(inserted));
      return true;
    } catch (e) {
      print("Add category error: $e");
      return false;
    }
  }

  Future<bool> updateCategory(
    String categoryId, {
    required String name,
    String? description,
  }) async {
    try {
      final updated = await supabase
          .from('categories')
          .update({
            "name": name,
            "description": description,
            "updated_at": DateTime.now().toIso8601String(),
          })
          .eq('category_id', categoryId)
          .select()
          .single();

      final index = categories.indexWhere(
        (c) => c.categoryId == updated['category_id'],
      );

      if (index != -1) {
        categories[index] = CategoryModel.fromJson(updated);
        categories.refresh();
      }
      return true;
    } catch (e) {
      print("Update category error: $e");
      return false;
    }
  }
}
