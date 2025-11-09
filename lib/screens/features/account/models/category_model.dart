class CategoryModel {
  final String categoryId;
  final String userId;
  final String name;
  final String? description;

  CategoryModel({
    required this.categoryId,
    required this.userId,
    required this.name,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "user_id": userId,
    "name": name,
    "description": description,
  };
}
