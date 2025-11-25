import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';
import '../controllers/categories_controller.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryController controller = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    controller.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor: AppColors.primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryPopup(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categories.isEmpty) {
          return _emptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return _categoryCard(category);
          },
        );
      }),
    );
  }

  // ✅ Unique Gradient Category Card -------------------------
  Widget _categoryCard(category) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.white.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF3DFA2), Color(0xFFE6C56F), Color(0xFFC79A32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON BOX
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.category, color: Colors.black, size: 26),
            ),

            const SizedBox(width: 16),

            // TEXT COLUMN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Description
                  if (category.description != null &&
                      category.description.isNotEmpty)
                    Text(
                      category.description ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // EDIT & DELETE BUTTONS COLUMN
            Column(
              children: [
                // EDIT
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _showUpdatePopup(context, category.categoryId),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(height: 10),

                // DELETE
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _confirmDelete(context, category.categoryId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.delete, color: Colors.red, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Empty State -------------------------------------------
  Widget _emptyState() {
    return Center(
      child: Text(
        "No categories found",
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Category",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete this category?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteCategory(
                  categoryId,
                ); // 🔥 CALL DELETE FUNCTION
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ Add Category Popup -------------------------------------
  void _showAddCategoryPopup(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 18),

              _inputField("Category Name", nameCtrl),
              const SizedBox(height: 14),

              _inputField("Description", descCtrl),

              const SizedBox(height: 20),

              _dialogActions(
                confirmText: "Add",
                onConfirm: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    Get.snackbar("Error", "Name is required");
                    return;
                  }

                  bool success = await controller.addCategory(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  );

                  if (success) {
                    Get.back();
                    Get.snackbar("Success", "Category added");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Update Category Popup ----------------------------------
  void _showUpdatePopup(BuildContext context, String categoryId) {
    final category = controller.categories.firstWhere(
      (c) => c.categoryId == categoryId,
    );

    final nameCtrl = TextEditingController(text: category.name);
    final descCtrl = TextEditingController(text: category.description);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Update Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 18),

              _inputField("Category Name", nameCtrl),
              const SizedBox(height: 14),

              _inputField("Description", descCtrl),

              const SizedBox(height: 20),

              _dialogActions(
                confirmText: "Save",
                onConfirm: () async {
                  bool success = await controller.updateCategory(
                    categoryId,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  );

                  if (success) {
                    Get.back();
                    Get.snackbar("Success", "Category updated");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Input Field Builder -----------------------------------
  Widget _inputField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ✅ Dialog Buttons Row -------------------------------------
  Widget _dialogActions({
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
          ),
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
