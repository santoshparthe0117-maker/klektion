import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';

import '../controllers/collection_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../models/collection_model.dart';

/// 🏠 Responsive Home Screen
class HomeScreen extends StatelessWidget {
  final dashboardController = Get.find<DashboardController>();
  final collectionController = Get.find<CollectionController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    final fontSize = isTablet ? 20.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.themeColor,
      body: SafeArea(
        child: GetBuilder<DashboardController>(
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
                          children: [
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
                                const CircleAvatar(
                                  backgroundColor: AppColors.accent,
                                  radius: 18,
                                  child: Icon(
                                    Icons.emoji_events,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(children: [const SizedBox(height: 4)]),
                            Text(
                              "Welcome back, Collector",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: fontSize - 2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Dashboard cards (responsive grid)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount = isTablet ? 3 : 3;
                                double cardWidth =
                                    (constraints.maxWidth - 24) /
                                    crossAxisCount;

                                final dashboardData =
                                    dashboardController.dashboardData;

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildDashboardCard(
                                      "Items",
                                      "${dashboardData.value!.monthlyChange}",
                                      cardWidth,
                                    ),
                                    _buildDashboardCard(
                                      "Total Value",
                                      "\$${dashboardData.value!.totalItems}k",
                                      cardWidth,
                                    ),
                                    _buildDashboardCard(
                                      "This Month",
                                      "+${dashboardData.value!.totalValue}%",
                                      cardWidth,
                                    ),
                                  ],
                                );
                              },
                            ),
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
                            _sectionHeader("My Collections"),
                            const SizedBox(height: 8),

                            // Collections list
                            Column(
                              children: collectionController.myCollections
                                  .map(
                                    (c) => _buildCollectionCard(
                                      context,
                                      c,
                                      isTablet: isTablet,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 24),

                            _sectionHeader("Recent Items"),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                "No recent items yet",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  /// Dashboard card (Items / Value / Growth)
  Widget _buildDashboardCard(String title, String value, double width) {
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Section header
  Widget _sectionHeader(String title) {
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
        const Text(
          "View All",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Collection card (with image error handling)
  Widget _buildCollectionCard(
    BuildContext context,
    CollectionModel c, {
    bool isTablet = false,
  }) {
    final imageSize = isTablet ? 100.0 : 80.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            c.imageUrl,
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
          c.title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        subtitle: Text(
          "${c.itemsCount} items",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "\$${c.value.toStringAsFixed(0)}",
            style: const TextStyle(color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  /// Bottom navigation
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: "Add",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
