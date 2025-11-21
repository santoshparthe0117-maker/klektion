import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';

import '../controllers/collections_controller.dart';
import 'collection_details.dart';
import 'create_collections.dart';

class CollectionsScreen extends StatelessWidget {
  final CollectionController controller = Get.put(CollectionController());
  final goldGradient = const LinearGradient(
    colors: [Color(0xFFB08A0B), Color(0xFFD4AF37), Color(0xFFFFE29F)],
  );

  CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.getCollections();

    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        title: const Text('Collections', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Get.to(() => CreateCollectionScreen()),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        "Create New Collection",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (controller.collections.isEmpty) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Image.asset(
                          'assets/images/no_data_found.png',
                          height: 150,
                          width: 1050,
                        ),
                        Text(
                          "No collections found",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.collections
                      .map((c) => _buildCollectionCard(context, c))
                      .toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCollectionCard(BuildContext context, dynamic collection) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2B25),
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: const Color.fromARGB(255, 114, 100, 52)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child:
                (collection.coverImageUrl != null &&
                    collection.coverImageUrl!.isNotEmpty)
                ? Image.network(
                    collection.coverImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  collection.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Divider(color: const Color.fromARGB(255, 121, 112, 91)),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${collection.itemCount.toString()} Items",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Get.to(
                          () => CollectionDetailsScreen(collection: collection),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "View Details",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
