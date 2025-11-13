import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klektion/utils/color_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/comments_controller.dart';

class CommentBottomSheet extends StatefulWidget {
  final String itemId;
  const CommentBottomSheet({super.key, required this.itemId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentController controller = Get.find<CommentController>();
  final TextEditingController commentCtrl = TextEditingController();

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.50,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2B22),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Comments",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (controller.comments.isEmpty) {
                    return const Center(
                      child: Text(
                        "No comments yet",
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: controller.comments.length,
                    itemBuilder: (_, i) {
                      final c = controller.comments[i];
                      final isMine =
                          c.userId ==
                          Supabase.instance.client.auth.currentUser?.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2A26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// USER AVATAR
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey.shade700,
                              backgroundImage:
                                  (c.userAvatar != null &&
                                      c.userAvatar!.isNotEmpty)
                                  ? NetworkImage(c.userAvatar!)
                                  : null,
                              child:
                                  (c.userAvatar == null ||
                                      c.userAvatar!.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 12),

                            /// COMMENT CONTENT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Username + Date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        c.userName ?? "Unknown User",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(c.createdAt),
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  /// COMMENT TEXT
                                  Text(
                                    c.comment,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  Container(height: 1, color: Colors.white10),

                                  /// DELETE BUTTON (Only mine)
                                  if (isMine)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          _showDeleteDialog(
                                            context,
                                            controller,
                                            c.commentId,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        label: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Obx(() {
                    return controller.isAdding.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () async {
                              if (commentCtrl.text.trim().isEmpty) return;

                              await controller.addComment(
                                widget.itemId,
                                commentCtrl.text.trim(),
                              );
                              commentCtrl.clear();
                            },
                          );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CommentController controller,
    String commentId,
  ) {
    Get.defaultDialog(
      title: "Delete Comment",
      middleText: "Are you sure you want to delete this comment?",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      middleTextStyle: const TextStyle(color: Colors.white70),
      backgroundColor: const Color(0xFF1C2B22),
      barrierDismissible: false,
      radius: 12,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () async {
            Get.back(); // close dialog

            bool success = await controller.deleteComment(commentId);
            if (success) {
              Get.snackbar(
                "Deleted",
                "Comment removed",
                backgroundColor: Colors.black54,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar(
                "Error",
                "Failed to delete comment",
                backgroundColor: Colors.black54,
                colorText: Colors.redAccent,
              );
            }
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
