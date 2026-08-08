import '../../../../core/constants/enums.dart';

/// User Model - Complete user data structure
class UserModel {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? photoUrl;
  final String? bio;
  final UserRole role;
  final String? officeId;
  final bool verified;
  final bool blocked;
  final double rating;
  final int totalReviews;
  final int totalProperties;
  final int totalFollowers;
  final int totalFollowing;
  final int totalViews;
  final int soldCount;
  final int rentedCount;
  final String? subscriptionId;
  final SubscriptionTier subscriptionTier;
  final List<String> fcmTokens;
  final List<String> deviceIds;
  final String language;
  final bool darkMode;
  final NotificationSettings notificationSettings;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.photoUrl,
    this.bio,
    this.role = UserRole.user,
    this.officeId,
    this.verified = false,
    this.blocked = false,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalProperties = 0,
    this.totalFollowers = 0,
    this.totalFollowing = 0,
    this.totalViews = 0,
    this.soldCount = 0,
    this.rentedCount = 0,
    this.subscriptionId,
    this.subscriptionTier = SubscriptionTier.free,
    this.fcmTokens = const [],
    this.deviceIds = const [],
    this.language = 'ar',
    this.darkMode = false,
    this.notificationSettings = const NotificationSettings(),
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      photoUrl: json['photo_url'] ?? json['photoUrl'],
      bio: json['bio'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      officeId: json['office_id'] ?? json['officeId'],
      verified: json['verified'] ?? false,
      blocked: json['blocked'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? json['totalReviews'] ?? 0,
      totalProperties: json['total_properties'] ?? json['totalProperties'] ?? 0,
      totalFollowers: json['total_followers'] ?? json['totalFollowers'] ?? 0,
      totalFollowing: json['total_following'] ?? json['totalFollowing'] ?? 0,
      totalViews: json['total_views'] ?? json['totalViews'] ?? 0,
      soldCount: json['sold_count'] ?? json['soldCount'] ?? 0,
      rentedCount: json['rented_count'] ?? json['rentedCount'] ?? 0,
      subscriptionId: json['subscription_id'] ?? json['subscriptionId'],
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (e) => e.name == (json['subscription_tier'] ?? json['subscriptionTier']),
        orElse: () => SubscriptionTier.free,
      ),
      fcmTokens: List<String>.from(json['fcm_tokens'] ?? json['fcmTokens'] ?? []),
      deviceIds: List<String>.from(json['device_ids'] ?? json['deviceIds'] ?? []),
      language: json['language'] ?? 'ar',
      darkMode: json['dark_mode'] ?? json['darkMode'] ?? false,
      notificationSettings: NotificationSettings.fromMap(
        json['notification_settings'] ?? json['notificationSettings'] ?? {},
      ),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return UserModel.fromJson(doc);
    return UserModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo_url': photoUrl,
      'bio': bio,
      'role': role.name,
      'office_id': officeId,
      'verified': verified,
      'blocked': blocked,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_properties': totalProperties,
      'total_followers': totalFollowers,
      'total_following': totalFollowing,
      'total_views': totalViews,
      'sold_count': soldCount,
      'rented_count': rentedCount,
      'subscription_id': subscriptionId,
      'subscription_tier': subscriptionTier.name,
      'fcm_tokens': fcmTokens,
      'device_ids': deviceIds,
      'language': language,
      'dark_mode': darkMode,
      'notification_settings': notificationSettings.toMap(),
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();


  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? bio,
    UserRole? role,
    String? officeId,
    bool? verified,
    bool? blocked,
    double? rating,
    int? totalReviews,
    int? totalProperties,
    int? totalFollowers,
    int? totalFollowing,
    int? totalViews,
    int? soldCount,
    int? rentedCount,
    String? subscriptionId,
    SubscriptionTier? subscriptionTier,
    List<String>? fcmTokens,
    List<String>? deviceIds,
    String? language,
    bool? darkMode,
    NotificationSettings? notificationSettings,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      officeId: officeId ?? this.officeId,
      verified: verified ?? this.verified,
      blocked: blocked ?? this.blocked,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalProperties: totalProperties ?? this.totalProperties,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalFollowing: totalFollowing ?? this.totalFollowing,
      totalViews: totalViews ?? this.totalViews,
      soldCount: soldCount ?? this.soldCount,
      rentedCount: rentedCount ?? this.rentedCount,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      deviceIds: deviceIds ?? this.deviceIds,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role.isAdmin;
  bool get isStaff => role.isStaff;
  bool get isOffice => role.isOffice;
}

/// Notification preferences
class NotificationSettings {
  final bool messages;
  final bool properties;
  final bool offers;
  final bool updates;

  const NotificationSettings({
    this.messages = true,
    this.properties = true,
    this.offers = true,
    this.updates = true,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      messages: map['messages'] ?? true,
      properties: map['properties'] ?? true,
      offers: map['offers'] ?? true,
      updates: map['updates'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messages': messages,
      'properties': properties,
      'offers': offers,
      'updates': updates,
    };
  }
}
