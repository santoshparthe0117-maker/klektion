import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_model.dart';

class DashboardController extends GetxController {
  final supabase = Supabase.instance.client;
  final dashboardData = Rxn<DashboardModel>();

  @override
  void onInit() {
    fetchDashboardData();
    super.onInit();
  }

  Future<void> fetchDashboardData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      dashboardData.value = DashboardModel(
        totalItems: 0,
        totalValue: 0.0,
        monthlyChange: 0.0,
      );
      return;
    }

    try {
      // 1) Fetch all items for user
      final allItemsResponse = await supabase
          .from('items')
          .select('item_id, estimated_value, created_at')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      final List allItems = (allItemsResponse as List?) ?? [];

      // ✅ total items
      final int totalItems = allItems.length;

      // ✅ total value (sum estimated_value)
      double totalValue = 0.0;
      for (final item in allItems) {
        final value = item['estimated_value'];

        if (value != null) {
          if (value is int) {
            totalValue += value.toDouble();
          } else if (value is double) {
            totalValue += value;
          } else if (value is num) {
            totalValue += value.toDouble();
          } else {
            // ignore invalid types
          }
        }
      }

      // 2) Items added this month (safe query)
      final firstOfMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        1,
      );

      final recentItemsResponse = await supabase
          .from('items')
          .select('item_id')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .gte('created_at', firstOfMonth.toIso8601String());

      final List recentItems = (recentItemsResponse as List?) ?? [];

      final int monthlyCount = recentItems.length;

      // Change = number of items added this month
      final double monthlyChange = monthlyCount.toDouble();

      dashboardData.value = DashboardModel(
        totalItems: totalItems,
        totalValue: totalValue,
        monthlyChange: monthlyChange,
      );
    } catch (e) {
      // fallback data if error occurs
      dashboardData.value = DashboardModel(
        totalItems: 0,
        totalValue: 0.0,
        monthlyChange: 0.0,
      );
      print("Dashboard error: $e");
    }
  }
}
