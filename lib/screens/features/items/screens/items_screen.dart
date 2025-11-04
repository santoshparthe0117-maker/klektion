import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/color_constants.dart';
import '../controllers/items_controller.dart';
import 'add_items_screen.dart';

class ProductScreen extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());
  final TextEditingController searchController = TextEditingController();

  ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Products', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.8,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔹 Add New Product Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Get.to(AddProductScreen());
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: greenGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline, color: Colors.white),
                      const Text(
                        'Add New Product',
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
              onChanged: (value) => controller.filteredProducts,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                hintText: 'Search products...',
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

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredProducts.isEmpty) {
                return const Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.65,
                ),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🖼️ Product Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            product.productName ?? '',
                            width: double.infinity,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 130,
                                  width: double.infinity,
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                          ),
                        ),

                        /// 📦 Product Info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Product Name
                                Text(
                                  product.productName ?? 'Unnamed Product',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                /// Description (optional)
                                if (product.productDescription != null)
                                  Text(
                                    product.productDescription!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),

                                /// 💰 Price + Actions
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// Price Section
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (product.discountAmount != null &&
                                            product.discountAmount! > 0)
                                          Text(
                                            "₹${product.discountedPrice?.toStringAsFixed(2) ?? '0.00'}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.green,
                                            ),
                                          ),
                                        if (product.discountAmount != null &&
                                            product.discountAmount! > 0)
                                          Text(
                                            "₹${product.productPrice?.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          )
                                        else
                                          Text(
                                            "₹${product.productPrice?.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                      ],
                                    ),

                                    /// Action Buttons
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          iconSize: 22,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            // controller.editProduct(product);
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          iconSize: 22,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            controller.deleteProduct(
                                              product.productId,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
