import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoverController extends GetxController {
  final supabase = Supabase.instance.client;

  // Tabs: trending / users / categories
  RxInt selectedTab = 0.obs;

  RxBool isLoading = false.obs;

  // Data lists
  RxList trendingCollections = [].obs;
  RxList topUsers = [].obs;
  RxList categories = [].obs;

  // Search text
  RxString searchQuery = "".obs;

  @override
  void onInit() {
    fetchTrendingCollections();
    fetchTopUsers();
    fetchCategories();
    super.onInit();
  }

  // ✅ Fetch trending collections
  Future<void> fetchTrendingCollections() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from("collections")
          .select("*, collection_images(image_url)")
          .limit(10);

      trendingCollections.value = response;
    } catch (e) {
      print("fetchTrendingCollections error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fetch users
  Future<void> fetchTopUsers() async {
    try {
      isLoading.value = true;

      final response = await supabase.from("users").select("*").limit(10);

      // Assign safely
      topUsers.value = response;
    } catch (e) {
      print("fetchTopUsers error: $e");
      topUsers.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fetch categories
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final response = await supabase.from("categories").select("""
          category_id,
          name,
          description,
          items:items(category_id)
        """);

      categories.value = (response as List).map((cat) {
        int itemCount = 0;

        if (cat["items"] != null && cat["items"] is List) {
          itemCount = (cat["items"] as List).length;
        }

        return {
          "category_id": cat["category_id"],
          "name": cat["name"],
          "description": cat["description"],
          "item_count": itemCount,
        };
      }).toList();
    } catch (e) {
      print("fetchCategories error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Search logic based on active tab
  List<dynamic> get filteredResults {
    if (searchQuery.isEmpty) {
      if (selectedTab.value == 0) return trendingCollections;
      if (selectedTab.value == 1) return topUsers;
      if (selectedTab.value == 2) return categories;
    }

    final q = searchQuery.value.toLowerCase();

    if (selectedTab.value == 0) {
      return trendingCollections
          .where((c) => c['name'].toLowerCase().contains(q))
          .toList();
    } else if (selectedTab.value == 1) {
      return topUsers
          .where((u) => u['name'].toLowerCase().contains(q))
          .toList();
    } else {
      return categories
          .where((cat) => cat['name'].toLowerCase().contains(q))
          .toList();
    }
  }
}
