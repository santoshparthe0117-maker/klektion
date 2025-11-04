import 'package:get/get.dart';
import '../models/collection_model.dart';

class CollectionController extends GetxController {
  var myCollections = <CollectionModel>[].obs;
  var recentItems = <CollectionModel>[].obs;

  @override
  void onInit() {
    fetchCollections();
    fetchRecentItems();
    super.onInit();
  }

  Future<void> fetchCollections() async {
    await Future.delayed(const Duration(milliseconds: 800));
    myCollections.value = [
      CollectionModel(
        title: "Rare Comics",
        itemsCount: 24,
        value: 15000,
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/en/9/9a/Superman%27s_Pal_Jimmy_Olsen_134.jpg",
      ),
      CollectionModel(
        title: "Luxury Watches",
        itemsCount: 8,
        value: 45000,
        imageUrl:
            "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
      ),
      CollectionModel(
        title: "Vintage Vinyl",
        itemsCount: 156,
        value: 8500,
        imageUrl:
            "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4",
      ),
    ];
  }

  Future<void> fetchRecentItems() async {
    await Future.delayed(const Duration(milliseconds: 600));
    recentItems.value = [
      CollectionModel(
        title: "Batman #1",
        itemsCount: 1,
        value: 5000,
        imageUrl: "https://upload.wikimedia.org/wikipedia/en/0/0c/Batman_1.jpg",
      ),
      CollectionModel(
        title: "Omega Seamaster",
        itemsCount: 1,
        value: 3500,
        imageUrl: "https://images.unsplash.com/photo-1503387762-592deb58ef4e",
      ),
    ];
  }
}
