import 'package:get/get.dart';
import 'package:klektion/controllers/image_controller.dart';
import '../controllers/auth_controller.dart';
import '../screens/features/account/controllers/categories_controller.dart';
import '../screens/features/account/controllers/profile_stats_controller.dart';
import '../screens/features/collections/controllers/collections_controller.dart';
import '../screens/features/discover/controllers/follows_controller.dart';
import '../screens/features/home/controllers/dashboard_controller.dart';
import '../screens/features/items/controllers/items_controller.dart';
import '../screens/features/wish_list/controller/wish_list_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CollectionController>(CollectionController(), permanent: true);
    Get.put<DashboardController>(DashboardController(), permanent: true);
    Get.put<ItemController>(ItemController(), permanent: true);
    Get.put<CategoryController>(CategoryController(), permanent: true);
    Get.put<WishlistController>(WishlistController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ProfileStatsController>(ProfileStatsController(), permanent: true);
    Get.put<ImageController>(ImageController(), permanent: true);
    Get.put<FollowController>(FollowController(), permanent: true);
  }
}
