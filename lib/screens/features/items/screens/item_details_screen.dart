import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';

import '../controllers/items_controller.dart';
import '../models/items_model.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId;
  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final ItemController itemController = Get.find<ItemController>();
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    itemController.getItemDetails(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A1A),
      body: Obx(() {
        if (itemController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = itemController.selectedItem.value;
        if (item == null) {
          return const Center(
            child: Text(
              "Item not found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerImage(item),
              const SizedBox(height: 16),
              _itemTitleSection(item),
              const SizedBox(height: 16),
              _valueSection(item),
              const SizedBox(height: 16),
              //gallery(item),
              _discription(item),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _headerImage(item) {
    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: item.images.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (_, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Image.network(
                  item.images[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        /// ✅ Dot Indicators
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              item.images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 12 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),

        /// ✅ Safe Back + Menu Buttons on Top
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: PopupMenuButton<String>(
                  color: const Color(0xFF1C3028),
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "edit",
                      child: Text("Edit Item"),
                    ),
                    const PopupMenuItem(value: "share", child: Text("Share")),
                    PopupMenuItem(
                      value: "delete",
                      child: Text(
                        "Delete Item",
                        style: TextStyle(color: Colors.red.shade300),
                      ),
                    ),
                  ],
                  onSelected: (value) {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemTitleSection(ItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          // Text(
          //   "${item.categoryName} • ${item.collectionName}",
          //   style: const TextStyle(color: Colors.white70),
          // ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.remove_red_eye, color: Colors.white60, size: 20),
              const SizedBox(width: 4),
              Text("234", style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 16),
              Icon(Icons.favorite_border, color: Colors.white60, size: 20),
              const SizedBox(width: 4),
              Text("89", style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 16),
              Icon(Icons.comment, color: Colors.white60, size: 20),
              const SizedBox(width: 4),
              Text("12", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueSection(ItemModel item) {
    double purchase = item.purchasePrice ?? 0;
    double currentValue = item.estimatedValue ?? 0;

    double profit = currentValue - purchase;

    double growthPercent = 0;
    bool isGrowth = profit >= 0;

    if (purchase > 0) {
      growthPercent = (profit / purchase) * 100;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _valueBox(
            title: "Current Value",
            value: "\$${currentValue.toStringAsFixed(2)}",
            growth: "${growthPercent.toStringAsFixed(1)}%",
            growthColor: isGrowth ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          _valueBox(
            title: "Purchase Price",
            value: "\$${purchase.toStringAsFixed(2)}",
            growth:
                "${isGrowth ? 'Profit' : 'Loss'} \$${profit.toStringAsFixed(2)}",
            growthColor: isGrowth ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _valueBox({
    required String title,
    required String value,
    required String growth,
    required Color growthColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F302C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              growth,
              style: TextStyle(color: growthColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discription(ItemModel item) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color.fromARGB(255, 133, 116, 78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Discription", style: TextStyle(color: AppColors.primaryColor)),
          SizedBox(height: 10),
          Text(item.description ?? '', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _gallery(ItemModel item) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(left: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: item.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.images[index],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
