import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/screens/features/items/controllers/items_controller.dart';
import 'package:klektion/screens/features/items/screens/item_details_screen.dart';
import 'package:klektion/utils/color_constants.dart';

import '../../items/models/items_model.dart'; // if you use custom colors

class CategoryItemsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  CategoryItemsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final ItemController controller = Get.find<ItemController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getItemsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.primaryColor, // back button color
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: AppColors.primaryColor, // title color
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingByCategory.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (controller.itemsByCategory.isEmpty) {
          return const Center(
            child: Text(
              "No items in this category",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.itemsByCategory.length,
          itemBuilder: (_, index) {
            final item = controller.itemsByCategory[index];
            return _itemCard(item);
          },
        );
      }),
    );
  }

  Widget _itemCard(ItemModel item) {
    final image = item.images.isNotEmpty ? item.images.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image != null
              ? Image.network(image, width: 60, height: 60, fit: BoxFit.cover)
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.image, color: Colors.white54),
                ),
        ),
        title: Text(item.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          item.description ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white54),
        ),
        // trailing: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Icon(
        //       item.isLiked ? Icons.favorite : Icons.favorite_border,
        //       color: item.isLiked ? Colors.red : Colors.white54,
        //     ),
        //     Text(
        //       "${item.likeCount}",
        //       style: const TextStyle(color: Colors.white70),
        //     ),
        //   ],
        // ),
        onTap: () {
          // navigate to your Item Details page
          Get.to(ItemDetailsScreen(itemId: item.itemId));
        },
      ),
    );
  }
}
