import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/color_constants.dart';
import '../controllers/collections_controller.dart';
import 'add_collections.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());
  final TextEditingController searchController = TextEditingController();

  CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.8,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔹 Add Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Get.to(AddCategoryScreen());
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: goldGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline, color: Colors.white),
                      const Text(
                        'Add New Category',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) => controller.filterCategories(value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                hintText: 'Search categories...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 Category List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredCategories.isEmpty) {
                return const Center(child: Text('No categories found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.filteredCategories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 219, 241, 219),
                          Color.fromARGB(255, 255, 255, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            20,
                            21,
                            20,
                          ).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: ClipOval(
                          child: Image.network(
                            category.categoryImagePath,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Show a placeholder image if the network image fails
                              return Image.asset(
                                'assets/images/shop_image.jpg', // your fallback image path
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),

                      title: Text(
                        category.categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Products",
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 10,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              // Show confirmation dialog
                              final confirm = await Get.defaultDialog<bool>(
                                title: 'Delete Category',
                                middleText:
                                    'Are you sure you want to delete this category?',
                                textCancel: 'Cancel',
                                textConfirm: 'Delete',
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  Get.back(result: true);
                                },
                                onCancel: () {
                                  Get.back(result: false);
                                },
                              );

                              // If confirmed, delete the category
                              if (confirm == true) {
                                controller.deleteCategory(
                                  category.productCategoryId,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
