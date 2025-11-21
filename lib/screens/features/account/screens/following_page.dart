import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../discover/controllers/follows_controller.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final FollowController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.fetchFollowingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Following", style: TextStyle(color: Colors.white)),
      ),

      body: Obx(() {
        if (controller.isLoadingFollowing.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        if (controller.followingList.isEmpty) {
          return const Center(
            child: Text(
              "You are not following anyone",
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.followingList.length,
          separatorBuilder: (_, __) =>
              Divider(height: 0, color: Colors.white12, thickness: 0.5),
          itemBuilder: (_, index) {
            final item = controller.followingList[index];
            final user = item['users'];

            final name = user['name'] ?? "Unknown User";
            final avatar = user['avatar_url'];
            final followingId = user['user_id'];

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
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: const Text(
                "Following",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),

              // ⭐ FOLLOW/UNFOLLOW BUTTON + MENU
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ------- FOLLOW BUTTON -------
                  Obx(() {
                    final isFollowing =
                        controller.isFollowingMap[followingId] ?? false;
                    final isRequested =
                        controller.requestSentMap[followingId] ?? false;

                    String buttonText = "Following";
                    Color bg = Colors.grey.shade800;
                    Color textColor = Colors.white;

                    if (isRequested) {
                      buttonText = "Requested";
                      bg = Colors.grey.shade700;
                      textColor = Colors.white;
                    } else if (!isFollowing) {
                      buttonText = "Follow";
                      bg = Colors.amber;
                      textColor = Colors.black;
                    }

                    return GestureDetector(
                      onTap: () {
                        controller.handleFollowTap(
                          targetUserId: followingId,
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

                  // ------- 3 DOT MENU -------
                  PopupMenuButton(
                    color: Colors.grey.shade900,
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "unfollow",
                        child: Row(
                          children: const [
                            Icon(
                              Icons.person_remove,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Unfollow",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "unfollow") {
                        controller.removeFromFollowing(followingId);
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
