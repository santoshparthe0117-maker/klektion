class CollectionModel {
  final String collectionId;
  final String userId;
  final String name;
  final String description;
  final String privacy;
  final String? coverImageUrl;
  final DateTime createdAt;
  final int itemCount;

  CollectionModel({
    required this.collectionId,
    required this.userId,
    required this.name,
    required this.description,
    required this.privacy,
    this.coverImageUrl,
    required this.createdAt,
    required this.itemCount,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    // ✅ Handle cover image safely
    String? coverImage;
    try {
      if (json['collection_images'] != null &&
          json['collection_images'] is List &&
          json['collection_images'].isNotEmpty) {
        coverImage = json['collection_images'][0]['image_url'];
      }
    } catch (_) {
      coverImage = null;
    }

    // ✅ Handle item count safely
    int count = 0;
    try {
      if (json['items'] != null &&
          json['items'] is List &&
          json['items'].isNotEmpty &&
          json['items'][0]['count'] != null) {
        count = json['items'][0]['count'] ?? 0;
      }
    } catch (_) {
      count = 0;
    }

    return CollectionModel(
      collectionId: json['collection_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      privacy: json['privacy'] ?? 'Private',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(), // fallback
      coverImageUrl: coverImage,
      itemCount: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collection_id': collectionId,
      'user_id': userId,
      'name': name,
      'description': description,
      'privacy': privacy,
      'cover_image_url': coverImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
