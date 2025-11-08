import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';

import '../controllers/collections_controller.dart';
import 'create_collections.dart';

class CollectionsScreen extends StatelessWidget {
  final CollectionController controller = Get.put(CollectionController());

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
              ElevatedButton.icon(
                onPressed: () => Get.to(() => CreateCollectionScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  "Create New Collection",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              ...controller.collections
                  .map((c) => _buildCollectionCard(context, c))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCollectionCard(BuildContext context, dynamic collection) {
    return Card(
      color: const Color(0xFF1B2B25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (collection.coverImageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                collection.coverImageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.grey.shade800,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                  ),
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
                const SizedBox(height: 8),
                Text(
                  "Privacy: ${collection.privacy}",
                  style: const TextStyle(color: Colors.amber, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
