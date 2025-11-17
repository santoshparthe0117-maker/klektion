import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:klektion/utils/color_constants.dart';

import '../../items/controllers/items_controller.dart';
import '../../items/models/items_model.dart';
import '../../items/screens/item_details_screen.dart';
import '../models/collection_model.dart';

class CollectionDetailsScreen extends StatefulWidget {
  final CollectionModel collection;

  const CollectionDetailsScreen({super.key, required this.collection});

  @override
  State<CollectionDetailsScreen> createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> {
  final ItemController itemController = Get.find<ItemController>();

  double totalValue = 0.0;
  double totalPurchase = 0.0;
  double growth = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
  }

  void getItems() async {
    await itemController.getItemsByCollection(widget.collection.collectionId);
    _calculateCollectionStats();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch collection items

    return Scaffold(
      backgroundColor: AppColors.themeColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Cover Image Section
            Stack(
              children: [
                /// Cover Image
                Container(
                  height: 260,
                  width: double.infinity,
                  child:
                      (widget.collection.coverImageUrl != null &&
                          widget.collection.coverImageUrl!.isNotEmpty)
                      ? Image.network(
                          widget.collection.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _emptyImage(),
                        )
                      : _emptyImage(),
                ),

                /// ✅ Gradient Overlay (for readability)
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(24),
                    //   bottomRight: Radius.circular(24),
                    // ),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                /// ✅ Back Button
                Positioned(
                  top: 40,
                  left: 16,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),

                /// ✅ More Options (Optional)
                Positioned(
                  top: 40,
                  right: 16,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                ),

                /// ✅ Title + Description over image
                Positioned(
                  left: 16,
                  bottom: 20,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.collection.name,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.collection.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Padding(
              padding: EdgeInsetsGeometry.only(right: 10, left: 10, top: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "${widget.collection.itemCount ?? 0} items",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Created ${_formatDate(widget.collection.createdAt)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ✅ Stats Cards
                  Row(
                    children: [
                      _smallCard("Total Value", totalValue.toString()),
                      const SizedBox(width: 12),
                      _smallCard(
                        "Growth",
                        "${growth.toStringAsFixed(2)}%",
                        green: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ✅ Items Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Items (${widget.collection.itemCount ?? 0})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Get.to(() => AddItemScreen());
                      //   },
                      //   child: const Text("Add Item"),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ✅ Items List
                  Obx(() {
                    if (itemController.isLoadingByCollection.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (itemController.itemListByCollection.isEmpty) {
                      return const Center(
                        child: Text(
                          "No items found",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return Column(
                      children: itemController.itemListByCollection.map((item) {
                        return _buildItemCard(item, context);
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateCollectionStats() {
    totalValue = 0.0;
    totalPurchase = 0.0;
    setState(() {
      for (var item in itemController.itemListByCollection) {
        final double estimated = item.estimatedValue ?? 0;
        final double purchased = item.purchasePrice ?? 0;

        totalValue += estimated;
        totalPurchase += purchased > 0 ? purchased : 0;
      }

      // Calculate growth %

      if (totalPurchase > 0) {
        growth = ((totalValue - totalPurchase) / totalPurchase) * 100;
      }
    });

    return {"totalValue": totalValue, "growth": growth};
  }

  Widget _emptyImage() {
    return Container(
      height: 220,
      color: Colors.grey.shade800,
      child: const Icon(Icons.image_not_supported, color: Colors.white),
    );
  }

  Widget _smallCard(String title, String value, {bool green = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: green ? Colors.greenAccent : Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ItemModel item, BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return InkWell(
      onTap: () {
        Get.to(() => ItemDetailsScreen(itemId: item.itemId));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B22),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.images.isNotEmpty
                  ? Image.network(
                      item.images.first,
                      width: isTablet ? 110 : 70,
                      height: isTablet ? 110 : 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: isTablet ? 110 : 70,
                        height: isTablet ? 110 : 70,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      width: isTablet ? 110 : 70,
                      height: isTablet ? 110 : 70,
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            /// ✅ Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // /// Category
                  // Text(
                  //   item.categoryName ?? "",
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: isTablet ? 14 : 12,
                  //   ),
                  // ),
                  const SizedBox(height: 6),

                  /// Price
                  Text(
                    "\$${item.estimatedValue ?? 0}",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: isTablet ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month} ${date.year}";
  }
}
