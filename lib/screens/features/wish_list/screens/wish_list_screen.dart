import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../items/models/items_model.dart';
import '../../items/screens/item_details_screen.dart';
import '../controller/wish_list_controller.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController wishlistController = Get.find<WishlistController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wishlistController.fetchWishlistItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A1A),
      appBar: AppBar(
        title: const Text("My Wishlist", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0E1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (wishlistController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wishlistController.wishlistItems.isEmpty) {
          return const Center(
            child: Text(
              "No items in wishlist",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wishlistController.wishlistItems.length,
          itemBuilder: (_, index) {
            final item = wishlistController.wishlistItems[index];

            return _wishlistCard(item);
          },
        );
      }),
    );
  }

  Widget _wishlistCard(ItemModel item) {
    return InkWell(
      onTap: () {
        Get.to(() => ItemDetailsScreen(itemId: item.itemId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.images.isNotEmpty ? item.images.first : "",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade800,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          title: Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: Text(
            "\$${item.estimatedValue?.toStringAsFixed(2) ?? '0'}",
            style: const TextStyle(color: Colors.white70),
          ),

          trailing: IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => wishlistController.removeFromWishlist(item.itemId),
          ),
        ),
      ),
    );
  }
}
