class CollectionModel {
  final String collectionId;
  final String userId;
  final String name;
  final String description;
  final String privacy;
  final String? coverImageUrl;
  final DateTime createdAt;

  CollectionModel({
    required this.collectionId,
    required this.userId,
    required this.name,
    required this.description,
    required this.privacy,
    this.coverImageUrl,
    required this.createdAt,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      collectionId: json['collection_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      privacy: json['privacy'] ?? 'Private',
      createdAt: DateTime.parse(json['created_at']),
      coverImageUrl:
          (json['collection_images'] != null &&
              (json['collection_images'] as List).isNotEmpty)
          ? (json['collection_images'] as List)
                .map((img) => img['image_url'] as String)
                .toList()[0]
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'privacy': privacy,
      'cover_image_url': coverImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
