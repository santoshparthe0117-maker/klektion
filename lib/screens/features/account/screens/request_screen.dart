import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/color_constants.dart';
import '../../discover/controllers/follows_controller.dart';

class FollowRequestsPage extends StatefulWidget {
  const FollowRequestsPage({super.key});

  @override
  State<FollowRequestsPage> createState() => _FollowRequestsPageState();
}

class _FollowRequestsPageState extends State<FollowRequestsPage> {
  final FollowController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.fetchIncomingRequests(); // API call at page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // <-- back button color
        title: const Text(
          "Follow Requests",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Obx(() {
        /// -------------------------
        ///  SHOW LOADING
        /// -------------------------
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 2,
            ),
          );
        }

        final requests = controller.incomingRequests;

        /// -------------------------
        /// EMPTY STATE
        /// -------------------------
        if (requests.isEmpty) {
          return const Center(
            child: Text(
              "No follow requests right now",
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          );
        }

        /// -------------------------
        /// REQUESTS LIST
        /// -------------------------
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          separatorBuilder: (_, __) =>
              Divider(height: 0, color: Colors.white12, thickness: 0.5),
          itemBuilder: (_, index) {
            final item = requests[index];
            final user = item['users'];
            final requestId = item['id'];
            final senderId = item['sender_id'];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              // Avatar
              leading: CircleAvatar(
                radius: 25,
                backgroundImage:
                    user['avatar_url'] != null &&
                        user['avatar_url'].toString().isNotEmpty
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child: user['avatar_url'] == null
                    ? const Icon(Icons.person, color: Colors.white70)
                    : null,
              ),

              // Name
              title: Text(
                user['name'] ?? "Unknown User",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: const Text(
                "wants to follow you",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),

              // Approve / Reject Buttons
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // APPROVE
                  GestureDetector(
                    onTap: () {
                      controller.approveRequestAction(requestId, senderId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Approve",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // REJECT
                  GestureDetector(
                    onTap: () {
                      controller.rejectRequestAction(requestId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
