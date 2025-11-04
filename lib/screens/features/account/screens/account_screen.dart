import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';

import '../../../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final authController = Get.find<AuthController>();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    double hPad = isTablet ? 24 : 16;
    double avatarSize = isTablet ? 90 : 70;
    double titleSize = isTablet ? 26 : 20;
    double subtitleSize = isTablet ? 15 : 13;
    double statCardSize = (size.width - (hPad * 2) - (isTablet ? 40 : 24)) / 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
            iconSize: isTablet ? 30 : 22,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(hPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: goldGradient,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 14),
              ),
              padding: EdgeInsets.all(isTablet ? 20 : 14),
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
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 10,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Premium Member",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: subtitleSize,
                          ),
                        ),
                      ),
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
                _statsCard("188", "Items", statCardSize, isTablet),
                _statsCard("1.2k", "Followers", statCardSize, isTablet),
                _statsCard("345", "Following", statCardSize, isTablet),
              ],
            ),

            SizedBox(height: isTablet ? 28 : 20),
            _sectionTitle("Privacy Controls", isTablet),
            _toggleTile("Public Profile", isTablet),
            _toggleTile("Show Item Values", isTablet),
            _toggleTile("Allow Comments", isTablet),

            SizedBox(height: isTablet ? 28 : 20),
            _sectionTitle("Social Activity", isTablet),
            _statLine(Icons.favorite, "Total Likes", "2,345", isTablet),
            _statLine(Icons.comment, "Comments", "567", isTablet),
            _statLine(Icons.share, "Shares", "123", isTablet),

            SizedBox(height: isTablet ? 28 : 20),
            _sectionTitle("Backup & Export", isTablet),
            _button("Export to CSV", isTablet),
            _button("Export to PDF", isTablet),
            _button("Cloud Backup", isTablet),
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
      ),
      child: Column(
        children: [
          Text(
            value,
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
      activeColor: Colors.amber,
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
}
