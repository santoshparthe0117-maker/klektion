import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_model.dart';

class CategoryController extends GetxController {
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<CategoryModel> filteredCategories = <CategoryModel>[].obs;
  RxBool isLoading = false.obs;
  var isLoadingAdd = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final path = 'categories/$fileName';
      await supabase.storage
          .from('category-images')
          .uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      final imageUrl = supabase.storage
          .from('category-images')
          .getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Insert category record into Supabase
  Future<bool> addCategory({
    required String categoryName,
    required String? categoryDescription,

    // required Uint8List? imageBytes,
  }) async {
    bool isSuccess = false;
    try {
      isLoading.value = true;

      final vendorId = supabase.auth.currentUser?.id;

      if (vendorId == null) {
        Get.snackbar('Error', 'User not authenticated.');
        return false;
      }

      // Upload image
      final imageUrl = '';
      // if (imageBytes != null) {
      //   final imageUrl = await uploadImage(
      //     imageBytes,
      //     '${DateTime.now().millisecondsSinceEpoch}.png',
      //   );
      // }

      final category = CategoryModelForPost(
        vendorId: vendorId,
        categoryName: categoryName,
        categoryDescription: categoryDescription,
        categoryImagePath: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await supabase
          .from('product_categories')
          .insert(category.toJson())
          .select();

      if (response.isNotEmpty) {
        // Map the response to your CategoryModel
        final newCategory = CategoryModel(
          productCategoryId: response[0]['product_category_id'].toString(),
          vendorId: response[0]['vendor_id'],
          categoryName: response[0]['category_name'],
          categoryDescription: response[0]['category_description'],
          categoryImagePath: response[0]['category_image_path'],
          isActive: response[0]['is_active'] ?? true,
          isDeleted: response[0]['is_deleted'] ?? false,
          createdAt: DateTime.parse(response[0]['created_at']),
          updatedAt: DateTime.parse(response[0]['updated_at']),
        );

        // Add the new category to the filteredCategories list
        filteredCategories.add(newCategory);
        isSuccess = true;
      } else {}
    } catch (e) {
      Get.snackbar('❌ Error', e.toString());
    } finally {
      isLoading.value = false;
    }
    return isSuccess;
  }

  void fetchCategories() async {
    try {
      isLoading.value = true;
      final vendorId = supabase.auth.currentUser?.id ?? '';

      // Fetch categories from Supabase
      final response = await supabase
          .from('product_categories')
          .select()
          .eq('vendor_id', vendorId) // filter by current vendor/user
          .eq('is_deleted', false) // optional: only active categories
          .order('created_at', ascending: true);

      if (response != null && response.isNotEmpty) {
        // Map the Supabase data to your CategoryModel
        final List<CategoryModel> categoriesList = (response as List)
            .map(
              (e) => CategoryModel(
                productCategoryId: e['product_category_id'].toString(),
                vendorId: e['vendor_id'],
                categoryName: e['category_name'],
                categoryDescription: e['category_description'],
                categoryImagePath: e['category_image_path'],
                isActive: e['is_active'] ?? true,
                isDeleted: e['is_deleted'] ?? false,
                createdAt: DateTime.parse(e['created_at']),
                updatedAt: DateTime.parse(e['updated_at']),
              ),
            )
            .toList();

        // Update filteredCategories observable
        filteredCategories.assignAll(categoriesList);
        categories.assignAll(categoriesList);
      } else {
        filteredCategories.clear(); // No categories found for this user
        categories.clear();
      }
    } catch (e) {
      print('Error fetching categories: $e');
      filteredCategories.clear();
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void filterCategories(String query) {
    if (query.isEmpty) {
      filteredCategories.assignAll(categories);
    } else {
      filteredCategories.assignAll(
        categories
            .where(
              (cat) => cat.categoryName.toLowerCase().contains(
                query.toLowerCase().trim(),
              ),
            )
            .toList(),
      );
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('product_categories')
          .update({'is_deleted': true})
          .eq('product_category_id', int.parse(categoryId))
          .select(); // 👈 Required to get data back

      if (response != null && response.isNotEmpty) {
        categories.removeWhere((c) => c.productCategoryId == categoryId);
        filteredCategories.removeWhere(
          (c) => c.productCategoryId == categoryId,
        );

        Get.snackbar('✅ Success', 'Category deleted successfully.');
      } else {
        // Even if response is null but query succeeded, handle gracefully
        categories.removeWhere((c) => c.productCategoryId == categoryId);
        filteredCategories.removeWhere(
          (c) => c.productCategoryId == categoryId,
        );
        Get.snackbar(
          '✅ Success',
          'Category deleted successfully (no response).',
        );
      }
    } catch (e) {
      Get.snackbar('❌ Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
