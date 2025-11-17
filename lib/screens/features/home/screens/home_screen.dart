import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/screens/features/collections/screens/create_collections.dart';
import 'package:klektion/screens/features/items/controllers/items_controller.dart';
import 'package:klektion/screens/features/items/screens/items_screen.dart';
import 'package:klektion/screens/features/wish_list/screens/wish_list_screen.dart';
import 'package:klektion/utils/color_constants.dart';

import '../../../../controllers/auth_controller.dart';
import '../../collections/controllers/collections_controller.dart';
import '../../collections/models/collection_model.dart';
import '../../collections/screens/collection_details.dart';
import '../../collections/screens/collections_screen.dart';
import '../../items/models/items_model.dart';
import '../../items/screens/item_details_screen.dart';
import '../../wish_list/controller/wish_list_controller.dart';
import '../controllers/dashboard_controller.dart';

/// 🏠 Responsive Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dashboardController = Get.find<DashboardController>();
  final authController = Get.find<AuthController>();

  final CollectionController collectionController =
      Get.find<CollectionController>();
  final ItemController itemController = Get.find<ItemController>();
  final WishlistController wishlistController = Get.find<WishlistController>();

  final goldGradient = const LinearGradient(
    colors: [Color(0xFFFFE29F), Color(0xFFD4AF37), Color(0xFFB08A0B)],
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ever(collectionController.isLoadingRecent, (_) {
      setState(() {});
    });

    ever(collectionController.recentCollections, (_) {
      setState(() {});
    });

    ever(itemController.isRecentLoading, (_) {
      setState(() {});
    });

    ever(itemController.recentItemList, (_) {
      setState(() {});
    });
    ever(wishlistController.isLoadingRecent, (_) {
      setState(() {});
    });

    ever(wishlistController.recentWishliItems, (_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    final fontSize = isTablet ? 20.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.themeColor,
      body: GetBuilder<DashboardController>(
        builder: (_) {
          return GetBuilder<CollectionController>(
            builder: (_) {
              return SingleChildScrollView(
                // padding: EdgeInsets.symmetric(
                //   // horizontal: horizontalPadding,
                //   vertical: 16,
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(60, 212, 175, 55),
                            AppColors.themeColor,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "My Collection",
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: fontSize + 4,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // const CircleAvatar(
                              //   backgroundColor: AppColors.accent,
                              //   radius: 18,
                              //   child: Icon(
                              //     Icons.emoji_events,
                              //     color: Colors.black,
                              //   ),
                              // ),
                            ],
                          ),
                          Column(children: [const SizedBox(height: 4)]),
                          Obx(() {
                            final user = authController.user;

                            if (user == null) {
                              return Text(
                                "Welcome back...",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: fontSize - 2,
                                ),
                              );
                            }

                            return Text(
                              "Welcome back, ${user.name}",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: fontSize - 2,
                              ),
                            );
                          }),
                          const SizedBox(height: 16),

                          // Dashboard cards (responsive grid)
                          Obx(() {
                            if (dashboardController.isDashboardLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final data =
                                dashboardController.dashboardData.value;
                            if (data == null) {
                              return Center(child: Container());
                            }

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                double cardWidth =
                                    (constraints.maxWidth - 24) /
                                    3; // 3 cards always

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildDashboardCard(
                                      "Items",
                                      "${data.totalItems}",
                                      cardWidth,
                                      Icons.inventory,
                                    ),
                                    _buildDashboardCard(
                                      "Total Value",
                                      "\$${data.totalValue}",
                                      cardWidth,
                                      Icons.attach_money,
                                    ),
                                    _buildDashboardCard(
                                      "This Month",
                                      "+${data.monthlyChange}",
                                      cardWidth,
                                      Icons.trending_up,
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _sectionHeader("My Collections", CollectionsScreen()),
                          const SizedBox(height: 8),

                          //  Collections list
                          if (collectionController.isLoadingRecent.value)
                            const Center(child: CircularProgressIndicator())
                          else if (collectionController
                              .recentCollections
                              .isEmpty)
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    height: 150,
                                    width: 1050,
                                    'assets/images/no_data_found.png',
                                  ),
                                  Text(
                                    "No collections found",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: collectionController.recentCollections
                                  .map((c) => _buildCollectionCard(context, c))
                                  .toList(),
                            ),

                          const SizedBox(height: 24),

                          _sectionHeader("Recent Items", ItemsScreen()),
                          const SizedBox(height: 8),
                          if (itemController.isRecentLoading.value)
                            const Center(child: CircularProgressIndicator())
                          else if (itemController.recentItemList.isEmpty)
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_data_found.png',
                                    height: 150,
                                    width: 1050,
                                  ),
                                  Text(
                                    "No recent items found",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: itemController.recentItemList
                                  .map((item) => buildRecentItemCard(item))
                                  .toList(),
                            ),
                          const SizedBox(height: 24),

                          _sectionHeader("Wish list", WishlistScreen()),
                          const SizedBox(height: 8),
                          if (wishlistController.isLoadingRecent.value)
                            const Center(child: CircularProgressIndicator())
                          else if (wishlistController.recentWishliItems.isEmpty)
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_data_found.png',
                                    height: 150,
                                    width: 1050,
                                  ),
                                  Text(
                                    "No wish list found",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: wishlistController.recentWishliItems
                                  .map((item) => buildRecentItemCard(item))
                                  .toList(),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.accent,
      //   onPressed: () {},
      //   child: const Icon(Icons.add, color: Colors.black),
      // ),
    );
  }

  /// Dashboard card (Items / Value / Growth)
  Widget _buildDashboardCard(
    String title,
    String value,
    double width,
    IconData icon,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Section header
  Widget _sectionHeader(String title, Widget route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: () {
            Get.to(() => route);
          },
          child: const Text(
            "View All",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget buildRecentItemCard(ItemModel item) {
    return InkWell(
      onTap: () {
        Get.to(() => ItemDetailsScreen(itemId: item.itemId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A22),
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(color: const Color.fromARGB(255, 114, 100, 52)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.images.isNotEmpty
                  ? Image.network(
                      item.images.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.image, color: Colors.white70),
                    ),
            ),

            const SizedBox(width: 12),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    item.name ?? "",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "\$${item.estimatedValue?.toStringAsFixed(0) ?? '0'}",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFFFD77A),
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

  // Collection card (with image error handling)
  Widget _buildCollectionCard(
    BuildContext context,
    CollectionModel collection, {
    bool isTablet = false,
  }) {
    final imageSize = isTablet ? 100.0 : 80.0;

    return InkWell(
      onTap: () {
        Get.to(() => CollectionDetailsScreen(collection: collection));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: BoxBorder.all(color: const Color.fromARGB(255, 114, 100, 52)),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              collection.coverImageUrl ?? '',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                );
              },
            ),
          ),
          title: Text(
            collection.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            "${collection.itemCount} items",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("", style: const TextStyle(color: AppColors.accent)),
          ),
        ),
      ),
    );
  }

  /// Bottom navigation
}
