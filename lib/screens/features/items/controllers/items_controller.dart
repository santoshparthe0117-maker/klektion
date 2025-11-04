import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../collections/models/collection_model.dart';
import '../models/items_model.dart';

class ProductController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  var isLoading = false.obs;
  var categories = [].obs;
  var subCategories = [].obs;
  var selectedCategory;
  var selectedSubCategory;
  var imageFiles = <Uint8List>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCategories();
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

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;

      final vendorId = supabase.auth.currentUser?.id;
      final response = await supabase
          .from('products')
          .select()
          .eq('vendor_id', vendorId!);

      products.value = (response as List<dynamic>)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      filteredProducts.assignAll(products);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.productId == id);
    filteredProducts.removeWhere((p) => p.productId == id);
  }

  // ✅ Upload image to Supabase Storage
  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    try {
      final path = 'products/$fileName';
      await supabase.storage
          .from('product_images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );
      return supabase.storage.from('product_images').getPublicUrl(path);
    } catch (e) {
      Get.snackbar('Error', 'Image upload failed: $e');
      return null;
    }
  }

  // ✅ Add product
  Future<bool> addProduct(AddProductModel product) async {
    try {
      isLoading.value = true;

      final response = await supabase.from('products').insert({
        'vendor_id': supabase.auth.currentUser?.id,
        'product_category_id': int.parse(product.categoryId),
        'product_name': product.productName,
        'product_description': product.description,
        'product_price': product.sellingPrice,
        'discount_amount': product.sellingPrice,
        'discounted_price': product.sellingPrice,
        'stock': product.stockQuantity,
        'is_active': true,
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isNotEmpty) {
        final newProduct = ProductModel.fromJson(response.first);
        products.insert(0, newProduct);
        filteredProducts.insert(0, newProduct);

        return true; // ✅ Success
      } else {
        Get.snackbar('⚠️ Failed', 'Could not add product.');
        return false; // ❌ Failure
      }
    } catch (e) {
      Get.snackbar('❌ Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
