import 'package:get/get.dart';
import '../models/dashboard_model.dart';

class DashboardController extends GetxController {
  var dashboardData = Rxn<DashboardModel>();

  @override
  void onInit() {
    fetchDashboardData();
    super.onInit();
  }

  Future<void> fetchDashboardData() async {
    // Simulate Supabase call
    await Future.delayed(const Duration(milliseconds: 800));
    dashboardData.value = DashboardModel(
      totalItems: 188,
      totalValue: 68500,
      monthlyChange: 12.3,
    );
  }
}
