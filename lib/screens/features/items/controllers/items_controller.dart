import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
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

  // Storage bucket name - you'll need to create this in Supabase
  static const String bucketName = 'item-images';

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

  Future pickImage({int limit = 4}) async {
    try {
      final picker = ImagePicker();
      // Use the older, more compatible method for multiple image selection
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        limit: limit,
      );

      return images;
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar('Error', 'Failed to pick images: $e');
      return null;
    }
  }

  /// Upload multiple images to Supabase storage
  Future<List<String>> uploadImages(List<XFile> images) async {
    if (images.isEmpty) return [];

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      List<String> uploadedUrls = [];

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final fileName = await _uploadSingleImage(image, userId);

        if (fileName != null) {
          final publicUrl = supabase.storage
              .from(bucketName)
              .getPublicUrl(fileName);
          uploadedUrls.add(publicUrl);
        }
      }

      return uploadedUrls;
    } catch (e) {
      print('Error uploading images: $e');
      Get.snackbar('Error', 'Failed to upload images: $e');
      return [];
    }
  }

  /// Upload single image file
  Future<String?> _uploadSingleImage(XFile image, String userId) async {
    try {
      final bytes = await image.readAsBytes();
      final fileExt = path.extension(image.path).toLowerCase();
      final fileName =
          '${userId}/${DateTime.now().millisecondsSinceEpoch}$fileExt';

      // Get MIME type
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';

      await supabase.storage
          .from(bucketName)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      return fileName;
    } catch (e) {
      print('Error uploading single image: $e');
      return null;
    }
  }

  /// Save image record to database
  Future<void> _saveImageRecord(String imageUrl, String itemId) async {
    try {
      await supabase.from('item_images').insert({
        'item_id': itemId,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving image record: $e');
    }
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
    required List<String> imageUrls,
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
      for (var imageUrl in imageUrls) {
        _saveImageRecord(imageUrl, itemId);
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
