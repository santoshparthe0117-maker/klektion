import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/color_constants.dart';
import '../../collections/models/collection_model.dart';
import '../../collections/screens/collection_details.dart';
import 'item_by_category.dart';
import '../controllers/discover_controller.dart';
import '../controllers/follows_controller.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final DiscoverController controller = Get.put(
    DiscoverController(),
    permanent: true,
  );
  final FollowController followController = Get.put(FollowController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(),
                const SizedBox(height: 12),
                _searchBar(),
                const SizedBox(height: 16),
                _tabs(),
                const SizedBox(height: 16),
                _sectionTitle(),
                const SizedBox(height: 16),
                Expanded(
                  child: controller.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : _listView(),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      "Discover",
      style: TextStyle(
        color: AppColors.accent,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (v) => controller.searchQuery.value = v,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search items, collections, or users...",
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.black26,
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _tabs() {
    List<String> tabs = ["Trending", "Users", "Categories"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        final isSelected = controller.selectedTab.value == index;

        return GestureDetector(
          onTap: () => controller.selectedTab.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.white24,
              ),
            ),
            child: Text(
              tabs[index],
              style: TextStyle(
                color: isSelected ? AppColors.accent : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionTitle() {
    List<String> titles = [
      "Trending Collections",
      "Top Collectors",
      "Categories",
    ];

    return Row(
      children: [
        const Icon(Icons.trending_up, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          titles[controller.selectedTab.value],
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _listView() {
    final results = controller.filteredResults;
    followController.loadFollowState(results);

    /// ✅ When Categories tab is selected → GridView
    if (controller.selectedTab.value == 2) {
      return GridView.builder(
        itemCount: results.length,
        padding: EdgeInsets.zero,
        // shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (_, i) => _categoryCard(results[i]),
      );
    }

    /// ✅ Trending + Users → Normal ListView
    return ListView.separated(
      itemCount: results.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        if (controller.selectedTab.value == 0) {
          return _trendingCard(results[i]);
        } else {
          return _userCard(results[i]);
        }
      },
    );
  }

  Widget _trendingCard(Map<String, dynamic> data) {
    final collection = CollectionModel.fromJson(data);
    return InkWell(
      onTap: () {
        Get.to(
          () =>
              CollectionDetailsScreen(collection: collection, isShowAdd: true),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                collection.coverImageUrl ?? "",
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, event) {
                  if (event == null) return child;
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: Colors.white54,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade900,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Row(
                  //   children: [
                  //     Text(
                  //       "${data['items_count']} items",
                  //       style: const TextStyle(color: Colors.white54),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Text(
                  //       "1200 followers",
                  //       style: const TextStyle(color: Colors.white54),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String? name) {
    if (name != null && name.isNotEmpty) {
      return Text(
        name[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return const Icon(Icons.person, color: Colors.white70);
  }

  Widget _userCard(dynamic user) {
    final userId = user['user_id'];
    final visibility = user['visibility']; // public / private

    // load follow status when widget builds
    //followController.loadFollowState(userId);

    return Obx(() {
      final isFollowing = followController.isFollowingMap[userId] ?? false;
      final isRequested = followController.requestSentMap[userId] ?? false;

      String buttonText = "Follow";
      Color bg = Colors.amber;
      Color textColor = Colors.black;

      if (isRequested) {
        buttonText = "Requested";
        bg = Colors.grey.shade700;
        textColor = Colors.white;
      } else if (isFollowing) {
        buttonText = "Following";
        bg = Colors.grey.shade800;
        textColor = Colors.white;
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade800,
              child: ClipOval(
                child:
                    (user['avatar_url'] != null &&
                        user['avatar_url'].toString().isNotEmpty)
                    ? Image.network(
                        user['avatar_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarFallback(user['name']);
                        },
                      )
                    : _buildAvatarFallback(user['name']),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              user['name'],
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            Spacer(),

            GestureDetector(
              onTap: () {
                followController.handleFollowTap(
                  targetUserId: userId,
                  visibility: visibility,
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _categoryCard(dynamic category) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () {
          Get.to(
            CategoryItemsScreen(
              categoryId: category["category_id"],
              categoryName: category["name"],
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.category, color: Colors.amber, size: 28),
            const SizedBox(height: 8),
            Text(
              category["name"] ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category["description"] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Spacer(),

            Text(
              "Items: ${category["item_count"] ?? 0}",
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
