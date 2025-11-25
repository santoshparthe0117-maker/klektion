class UserModel {
  final String userId;
  final String userTypeId;
  final String name;
  final String email;
  final String passwordHash;
  final String mobile;
  final String avatarUrl; // ✅ NEW
  final String bio; // ✅ NEW
  final bool isActive;
  final bool isDeleted;
  final bool hasRequestedVendorApproval;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.userTypeId,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.mobile,
    required this.avatarUrl, // added
    required this.bio, // added
    required this.isActive,
    required this.isDeleted,
    required this.hasRequestedVendorApproval,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory method to create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      userTypeId: json['user_type_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['password_hash'] ?? '',
      mobile: json['mobile'] ?? '',
      avatarUrl: json['avatar_url'] ?? '', // added
      bio: json['bio'] ?? '', // added
      isActive: json['is_active'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      hasRequestedVendorApproval:
          json['has_requested_vendor_approval'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_type_id': userTypeId,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'mobile': mobile,
      'avatar_url': avatarUrl, // added
      'bio': bio, // added
      'is_active': isActive,
      'is_deleted': isDeleted,
      'has_requested_vendor_approval': hasRequestedVendorApproval,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// CopyWith for immutability
  UserModel copyWith({
    String? userId,
    String? userTypeId,
    String? name,
    String? email,
    String? passwordHash,
    String? mobile,
    String? avatarUrl, // added
    String? bio, // added
    bool? isActive,
    bool? isDeleted,
    bool? hasRequestedVendorApproval,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userTypeId: userTypeId ?? this.userTypeId,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      mobile: mobile ?? this.mobile,
      avatarUrl: avatarUrl ?? this.avatarUrl, // added
      bio: bio ?? this.bio, // added
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      hasRequestedVendorApproval:
          hasRequestedVendorApproval ?? this.hasRequestedVendorApproval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, email: $email, mobile: $mobile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.userId == userId && other.email == email;
  }

  @override
  int get hashCode => userId.hashCode ^ email.hashCode;
}
