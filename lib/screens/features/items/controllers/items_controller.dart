import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/items_model.dart';

class ItemController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  RxList<ItemModel> itemList = <ItemModel>[].obs;
  RxList<ItemModel> filteredItems = <ItemModel>[].obs;

  var isLoading = false.obs;
  var categories = [].obs;
  var subCategories = [].obs;
  var selectedCategory;
  var selectedSubCategory;
  var imageFiles = <Uint8List>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   getItemsByUser();
  //   fetchCategories();
  // }

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
        categories.value = response;
      } else {
        categories.clear(); // No categories found for this user
      }
    } catch (e) {
      print('Error fetching categories: $e');
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getItemsByUser() async {
    try {
      isLoading.value = true;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print("⚠️ No logged-in user");
        return;
      }

      final response = await supabase
          .from('items')
          .select('*, item_images(image_url)')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      itemList.value = data.map((e) => ItemModel.fromJson(e)).toList();
      filteredItems.value = [...itemList]; // copy list
    } catch (e) {
      print('❌ Error fetching items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void deleteItems(String id) {
    itemList.removeWhere((p) => p.itemId == id);
    filteredItems.removeWhere((p) => p.itemId == id);
  }

  // ✅ Add product
  RxList<File> images = <File>[].obs;
  final picker = ImagePicker();

  Future pickImage() async {
    if (images.length >= 4) return;
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      images.add(File(picked.path));
    }
  }

  Future<String> uploadImage(String itemId, File file) async {
    final fileName = "$itemId-${DateTime.now().millisecondsSinceEpoch}.jpg";
    final path = 'items/$fileName';

    await supabase.storage.from('item_images').upload(path, file);

    return supabase.storage.from('item_images').getPublicUrl(path);
  }

  Future<bool> addItem({
    required String name,
    required String collectionId,
    required String? categoryId,
    required double? purchasePrice,
    required double? estimatedValue,
    required String description,
    required String visibility, // private / public
    DateTime? acquisitionDate,
    String? condition,
  }) async {
    try {
      isLoading.value = true;

      // ✅ Get current logged-in user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print("⚠️ User not logged in");
        return false;
      }

      final itemData = {
        'user_id': userId, // ✅ added here
        'collection_id': collectionId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'purchase_price': purchasePrice,
        'estimated_value': estimatedValue,
        'acquisition_date': acquisitionDate?.toIso8601String(),
        'condition': condition,
        'visibility': visibility,
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // ✅ Insert & get returned row
      final inserted = await supabase
          .from('items')
          .insert(itemData)
          .select()
          .single();

      final String itemId = inserted['item_id'];

      // ✅ Upload images and insert into item_images table
      for (var file in images) {
        final url = await uploadImage(itemId, file);
        await supabase.from('item_images').insert({
          'item_id': itemId,
          'image_url': url,
        });
      }

      return true;
    } catch (e) {
      print("Add item error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
