class CommentModel {
  final String commentId;
  final String userId;
  final String itemId;
  final String comment;
  final DateTime createdAt;
  final bool isDeleted;

  final String userName;
  final String? userAvatar;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.itemId,
    required this.comment,
    required this.createdAt,
    required this.isDeleted,
    required this.userName,
    this.userAvatar,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['comment_id'],
      userId: json['user_id'],
      itemId: json['item_id'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      isDeleted: json['is_deleted'] ?? false,

      // User details from join
      userName: json['user']?['name'] ?? "Unknown",
      userAvatar: json['user']?['avatar_url'],
    );
  }
}
