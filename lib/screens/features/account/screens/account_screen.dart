import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/screens/features/auth/screens/signin_screen.dart';
import 'package:klektion/utils/color_constants.dart';

import '../../../../controllers/auth_controller.dart';
import '../controllers/profile_stats_controller.dart';
import 'categories_scrern.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authController = Get.find<AuthController>();

  final ProfileStatsController stats = Get.find<ProfileStatsController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stats.fetchProfileStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    double hPad = isTablet ? 24 : 14;
    double avatarSize = isTablet ? 90 : 70;
    double titleSize = isTablet ? 26 : 20;
    double subtitleSize = isTablet ? 15 : 13;
    double statCardSize = (size.width - (hPad * 2) - (isTablet ? 40 : 24)) / 3;

    final goldGradient = const LinearGradient(
      colors: [
        Color.fromARGB(153, 114, 101, 73),
        Color.fromARGB(137, 108, 89, 28),
        Color.fromARGB(130, 167, 130, 9),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.themeColor,

      body: SingleChildScrollView(
        // padding: EdgeInsets.all(hPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(gradient: goldGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      //  gradient: goldGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 14),
                    ),
                    padding: EdgeInsets.all(isTablet ? 10 : 5),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: avatarSize / 2,
                          backgroundImage: NetworkImage(
                            "https://avatars.githubusercontent.com/u/583231?v=4",
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? "Collector",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.email ?? "",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: subtitleSize,
                              ),
                            ),
                            SizedBox(height: 6),
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: isTablet ? 12 : 10,
                            //     vertical: isTablet ? 6 : 4,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: Colors.black.withOpacity(0.25),
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child: Text(
                            //     "Premium Member",
                            //     style: TextStyle(
                            //       color: Colors.amber,
                            //       fontSize: subtitleSize,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 24 : 18),

                  // Stats Cards Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => _statsCard(
                          stats.totalItems.value.toString(),
                          "Items",
                          statCardSize,
                          isTablet,
                        ),
                      ),
                      Obx(
                        () => _statsCard(
                          stats.totalFollowers.value.toString(),
                          "Followers",
                          statCardSize,
                          isTablet,
                        ),
                      ),
                      Obx(
                        () => _statsCard(
                          stats.totalFollowing.value.toString(),
                          "Following",
                          statCardSize,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGradientCard(
                    icon: Icons.category,
                    title: "Manage Categories",
                    onTap: () {
                      Get.to(() => CategoriesScreen());
                    },
                  ),
                  SizedBox(height: isTablet ? 28 : 20),
                  _sectionTitle("Privacy Controls", isTablet),
                  _toggleTile("Public Profile", isTablet),

                  //  _toggleTile("Show Item Values", isTablet),
                  //  _toggleTile("Allow Comments", isTablet),
                  SizedBox(height: isTablet ? 28 : 20),
                  _sectionTitle("Social Activity", isTablet),
                  Obx(
                    () => _statLine(
                      Icons.favorite,
                      "Total Likes",
                      stats.totalLikes.value.toString(),
                      isTablet,
                    ),
                  ),

                  Obx(
                    () => _statLine(
                      Icons.comment,
                      "Comments",
                      stats.totalComments.value.toString(),
                      isTablet,
                    ),
                  ),

                  //  _statLine(Icons.share, "Shares", "123", isTablet),
                  SizedBox(height: isTablet ? 28 : 20),
                  _sectionTitle("Backup & Export", isTablet),
                  SizedBox(height: isTablet ? 28 : 20),
                  _button("Export to CSV", isTablet),
                  _button("Export to PDF", isTablet),

                  //  _button("Cloud Backup", isTablet),
                  GestureDetector(
                    onTap: () => _showLogoutConfirm(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE53935), // deep red
                            Color(0xFFF44336), // lighter red
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color.fromARGB(173, 201, 170, 97),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  // ✅ Widgets Below
  Widget _statsCard(String value, String title, double w, bool tab) {
    return Container(
      width: w,
      padding: EdgeInsets.symmetric(vertical: tab ? 22 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A2B),
        borderRadius: BorderRadius.circular(tab ? 16 : 12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: tab ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: tab ? 16 : 13),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, bool tab) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.amber,
        fontSize: tab ? 20 : 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _collectionCard({
    required String img,
    required String title,
    required String count,
    required bool isPrivate,
    required bool isTablet,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF122021),
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            img,
            width: isTablet ? 70 : 55,
            height: isTablet ? 70 : 55,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 18 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          count,
          style: TextStyle(color: Colors.white70, fontSize: isTablet ? 14 : 12),
        ),
        trailing: Icon(
          isPrivate ? Icons.lock : Icons.visibility,
          color: Colors.white70,
          size: isTablet ? 26 : 20,
        ),
      ),
    );
  }

  Widget _toggleTile(String label, bool isTablet) {
    return SwitchListTile(
      value: true,
      onChanged: (value) {},
      activeThumbColor: Colors.amber,
      title: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: isTablet ? 18 : 15),
      ),
    );
  }

  Widget _statLine(IconData icon, String name, String value, bool tab) {
    return ListTile(
      dense: !tab,
      leading: Icon(icon, color: Colors.amber, size: tab ? 26 : 20),
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontSize: tab ? 18 : 15),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.white70, fontSize: tab ? 18 : 15),
      ),
    );
  }

  Widget _button(String text, bool tab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: tab ? 55 : 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(tab ? 14 : 10),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: tab ? 18 : 15),
        ),
      ),
    );
  }

  Widget _buildGradientCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFB38A2D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirm() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 32),
              ),

              const SizedBox(height: 16),

              // Title
              const Text(
                "Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Logout Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        Get.back(); // Close dialog first

                        final success = await Get.find<AuthController>()
                            .logout();

                        if (success) {
                          Get.offAll(() => SignInScreen());
                        } else {
                          Get.snackbar(
                            "Error",
                            "Logout failed, try again!",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
