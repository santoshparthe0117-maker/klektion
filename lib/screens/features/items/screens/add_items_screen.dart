import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/collection_controller.dart';
import '../controllers/items_controller.dart';
import '../models/items_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final CollectionController categoriesController = Get.put(
    CollectionController(),
  );
  final ProductController controller = Get.put(ProductController());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      final files = result.files
          .where((f) => f.bytes != null)
          .take(8)
          .map((f) => f.bytes!)
          .toList();
      controller.imageFiles.assignAll(files);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Product',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Product Images',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: pickImages,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: themeColor.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFF6FFF6),
                  ),
                  child: Obx(() {
                    if (controller.imageFiles.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 35,
                              color: Colors.green,
                            ),
                            SizedBox(height: 8),
                            Text('Upload up to 8 images'),
                          ],
                        ),
                      );
                    } else {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.imageFiles
                            .map(
                              (img) => Image.memory(
                                img,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                            .toList(),
                      );
                    }
                  }),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              Obx(
                () => DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedCategory,
                  items: controller.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat['product_category_id'],
                          child: Text(cat['category_name']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    controller.selectedCategory = value;
                    categoriesController.fetchCollections();
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Subcategory dropdown
              Obx(
                () => DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Select Sub-category',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedSubCategory,
                  items: controller.subCategories
                      .map(
                        (sub) => DropdownMenuItem(
                          value: sub['subcategory_id'],
                          child: Text(sub['subcategory_name']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => controller.selectedSubCategory = value,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: mrpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'MRP (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Product Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await controller.addProduct(
                              AddProductModel(
                                productName: nameController.text,
                                categoryId: controller.selectedCategory
                                    .toString(),
                                subCategoryId:
                                    controller.selectedSubCategory ?? '',
                                brandName: brandController.text,
                                mrp: double.tryParse(mrpController.text) ?? 0,
                                sellingPrice:
                                    double.tryParse(priceController.text) ?? 0,
                                stockQuantity: int.parse(stockController.text),
                                sku: skuController.text,
                                description: descController.text,
                              ),
                            );

                            if (success) {
                              Get.back(); // ⬅️ Go back only if product successfully added
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Product',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
