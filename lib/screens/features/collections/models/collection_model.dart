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
      coverImageUrl: json['cover_image_url'],
      createdAt: DateTime.parse(json['created_at']),
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
