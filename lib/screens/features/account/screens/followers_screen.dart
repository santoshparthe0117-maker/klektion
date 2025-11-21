import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';
import '../../discover/controllers/follows_controller.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({super.key});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  final FollowController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.fetchFollowersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        title: const Text("Followers", style: TextStyle(color: Colors.white)),
      ),

      body: Obx(() {
        if (controller.isLoadingFollowers.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        if (controller.followersList.isEmpty) {
          return const Center(
            child: Text(
              "No followers yet",
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.followersList.length,
          separatorBuilder: (_, __) =>
              Divider(height: 0, color: Colors.white12, thickness: 0.5),
          itemBuilder: (_, index) {
            final item = controller.followersList[index];
            final user = item['users'];

            final followerName = user['name'] ?? "Unknown User";
            final avatar = user['avatar_url'];
            final followerId = user['user_id'];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              leading: CircleAvatar(
                radius: 25,
                backgroundImage: avatar != null && avatar.toString().isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar == null
                    ? const Icon(Icons.person, color: Colors.white70)
                    : null,
              ),

              title: Text(
                followerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: const Text(
                "Follower",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),

              // ⭐ ADD 3 DOT MORE OPTIONS
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Follow/Requested/Following button
                  Obx(() {
                    final isFollowing =
                        controller.isFollowingMap[followerId] ?? false;
                    final isRequested =
                        controller.requestSentMap[followerId] ?? false;

                    String buttonText = "Follow Back";
                    Color bg = Colors.amber;
                    Color textColor = Colors.black;

                    if (isRequested) {
                      buttonText = "Requested";
                      bg = Colors.grey.shade700;
                      textColor = Colors.white;
                    } else if (isFollowing) {
                      buttonText = "Following";
                      bg = Colors.grey.shade800;
                      textColor = Colors.white;
                    }

                    return GestureDetector(
                      onTap: () {
                        controller.handleFollowTap(
                          targetUserId: followerId,
                          visibility: "public",
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                          border: isFollowing
                              ? Border.all(color: Colors.white54)
                              : null,
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(width: 10),

                  // ⭐ REMOVE FOLLOWER MENU
                  PopupMenuButton(
                    color: Colors.grey.shade900,
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "remove",
                        child: Row(
                          children: const [
                            Icon(
                              Icons.person_remove,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Remove follower",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "remove") {
                        controller.removeFollower(followerId);
                      }
                    },
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
