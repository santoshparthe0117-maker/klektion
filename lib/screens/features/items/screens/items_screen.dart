import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/color_constants.dart';
import '../controllers/items_controller.dart';
import 'add_items_screen.dart';
import 'item_details_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final ItemController itemController = Get.put(ItemController());

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        title: const Text('My Items', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,

        // ✅ add gradient here
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFB38A2D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          // TODO: Add item screen
          bool? result = await Get.to(() => AddItemScreen());
          if (result == true) {
            await itemController.getItemsByUser();
            if (mounted) {
              setState(() {});
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Column(
        children: [
          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: searchController,
              onChanged: (value) => itemController.filterItems(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search items...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1C2B2B),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (itemController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (itemController.filteredItems.isEmpty) {
                return const Center(
                  child: Text(
                    'No items found',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                itemCount: itemController.filteredItems.length,
                itemBuilder: (context, index) {
                  final item = itemController.filteredItems[index];

                  final image = item.images.isNotEmpty
                      ? item.images.first
                      : null;

                  return InkWell(
                    onTap: () {
                      Get.to(() => ItemDetailsScreen(itemId: item.itemId));
                    },
                    child: Card(
                      color: const Color(0xFF122021),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: AppColors.accent.withOpacity(0.4),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: image != null
                              ? Image.network(
                                  image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _placeholder(),
                                )
                              : _placeholder(),
                        ),

                        title: Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (item.estimatedValue != null)
                              Text(
                                "Value: \$${item.estimatedValue!.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            if (item.purchasePrice != null)
                              Text(
                                "Purchase: \$${item.purchasePrice!.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),

                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          color: Colors.white,
                          onSelected: (value) async {
                            if (value == "edit") {
                              // TODO Edit item page
                              bool? result = await Get.to(
                                () => AddItemScreen(item: item),
                              );
                              if (result == true) {
                                await itemController.getItemsByUser();
                                if (mounted) {
                                  setState(() {});
                                }
                              }
                            } else if (value == "delete") {
                              _showDeleteItemDialog(item.itemId);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: "edit",
                              child: Text("Edit"),
                            ),
                            const PopupMenuItem(
                              value: "delete",
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
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

  void _showDeleteItemDialog(String itemId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.themeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Delete Item?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete this item?\nThis action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.back(); // close dialog immediately

                final ok = await itemController.deleteItem(itemId);

                if (ok) {
                  Get.snackbar(
                    "Deleted",
                    "Item removed successfully",
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    "Error",
                    "Failed to delete item",
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.black26,
      child: const Icon(Icons.image_not_supported, color: Colors.white70),
    );
  }
}
