import 'package:get/get.dart';
import '../screens/features/home/controllers/collection_controller.dart';
import '../screens/features/home/controllers/dashboard_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CollectionController>(CollectionController(), permanent: true);
    Get.put<DashboardController>(DashboardController(), permanent: true);
  }
}
