import '../../../core/constants/enums.dart';

/// Helper to parse DateTime from String, int, or DateTime
DateTime _parseDate(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is DateTime) return val;
  if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
  return DateTime.now();
}

/// Message Model for real-time chat
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? replyToId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? fileName;
  final double? latitude;
  final double? longitude;
  final int? duration; // for voice messages
  final MessageStatus status;
  final bool edited;
  final bool deleted;
  final DateTime createdAt;
  final DateTime? editedAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.replyToId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.fileName,
    this.latitude,
    this.longitude,
    this.duration,
    this.status = MessageStatus.sending,
    this.edited = false,
    this.deleted = false,
    required this.createdAt,
    this.editedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id']?.toString() ?? '',
      conversationId: data['conversation_id'] ?? data['conversationId'] ?? '',
      senderId: data['sender_id'] ?? data['senderId'] ?? '',
      replyToId: data['reply_to_id'] ?? data['replyToId'],
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      content: data['content'] ?? '',
      mediaUrl: data['media_url'] ?? data['mediaUrl'],
      fileName: data['file_name'] ?? data['fileName'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      duration: data['duration'],
      status: MessageStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      edited: data['edited'] ?? false,
      deleted: data['deleted'] ?? false,
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
      editedAt: data['edited_at'] != null || data['editedAt'] != null
          ? _parseDate(data['edited_at'] ?? data['editedAt'])
          : null,
    );
  }

  factory MessageModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return MessageModel.fromJson(doc);
    return MessageModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'reply_to_id': replyToId,
      'type': type.name,
      'content': content,
      'media_url': mediaUrl,
      'file_name': fileName,
      'latitude': latitude,
      'longitude': longitude,
      'duration': duration,
      'status': status.name,
      'edited': edited,
      'deleted': deleted,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? replyToId,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? fileName,
    double? latitude,
    double? longitude,
    int? duration,
    MessageStatus? status,
    bool? edited,
    bool? deleted,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      replyToId: replyToId ?? this.replyToId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      edited: edited ?? this.edited,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}

/// Conversation Model
class ConversationModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final MessageType? lastMessageType;
  final String? lastSenderId;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final Map<String, bool> typing;
  final Map<String, DateTime?> lastSeen;
  final Map<String, bool> blocked;
  final String? propertyId;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageType,
    this.lastSenderId,
    this.lastMessageAt,
    this.unreadCount = const {},
    this.typing = const {},
    this.lastSeen = const {},
    this.blocked = const {},
    this.propertyId,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> data) {
    return ConversationModel(
      id: data['id']?.toString() ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['last_message'] ?? data['lastMessage'],
      lastMessageType: (data['last_message_type'] ?? data['lastMessageType']) != null
          ? MessageType.values.firstWhere(
              (e) => e.name == (data['last_message_type'] ?? data['lastMessageType']),
              orElse: () => MessageType.text,
            )
          : null,
      lastSenderId: data['last_sender_id'] ?? data['lastSenderId'],
      lastMessageAt: data['last_message_at'] != null || data['lastMessageAt'] != null
          ? _parseDate(data['last_message_at'] ?? data['lastMessageAt'])
          : null,
      unreadCount: Map<String, int>.from(data['unread_count'] ?? data['unreadCount'] ?? {}),
      typing: Map<String, bool>.from(data['typing'] ?? {}),
      lastSeen: (data['last_seen'] ?? data['lastSeen'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v != null ? _parseDate(v) : null),
          ) ??
          {},
      blocked: Map<String, bool>.from(data['blocked'] ?? {}),
      propertyId: data['property_id'] ?? data['propertyId'],
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  factory ConversationModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return ConversationModel.fromJson(doc);
    return ConversationModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'last_message': lastMessage,
      'last_message_type': lastMessageType?.name,
      'last_sender_id': lastSenderId,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'typing': typing,
      'last_seen': lastSeen.map((k, v) => MapEntry(k, v?.toIso8601String())),
      'blocked': blocked,
      'property_id': propertyId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  /// Get the other user's ID in a 1:1 conversation
  String otherUserId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  int getUnreadCount(String userId) => unreadCount[userId] ?? 0;
  bool isTyping(String userId) => typing[userId] ?? false;
  bool isBlocked(String userId) => blocked[userId] ?? false;
}

/// Notification Model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? targetId;
  final String? imageUrl;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.targetId,
    this.imageUrl,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id']?.toString() ?? '',
      userId: data['user_id'] ?? data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      targetId: data['target_id'] ?? data['targetId'],
      imageUrl: data['image_url'] ?? data['imageUrl'],
      read: data['read'] ?? false,
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  factory NotificationModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return NotificationModel.fromJson(doc);
    return NotificationModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'target_id': targetId,
      'image_url': imageUrl,
      'read': read,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}

/// Review Model
class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewedUserId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> data) {
    return ReviewModel(
      id: data['id']?.toString() ?? '',
      reviewerId: data['reviewer_id'] ?? data['reviewerId'] ?? '',
      reviewedUserId: data['reviewed_user_id'] ?? data['reviewedUserId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'],
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  factory ReviewModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return ReviewModel.fromJson(doc);
    return ReviewModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewer_id': reviewerId,
      'reviewed_user_id': reviewedUserId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}

/// Report Model
class ReportModel {
  final String id;
  final String reporterId;
  final String propertyId;
  final ReportReason reason;
  final String? details;
  final String status; // pending, reviewed, resolved
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.propertyId,
    required this.reason,
    this.details,
    this.status = 'pending',
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> data) {
    return ReportModel(
      id: data['id']?.toString() ?? '',
      reporterId: data['reporter_id'] ?? data['reporterId'] ?? '',
      propertyId: data['property_id'] ?? data['propertyId'] ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.name == data['reason'],
        orElse: () => ReportReason.other,
      ),
      details: data['details'],
      status: data['status'] ?? 'pending',
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  factory ReportModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return ReportModel.fromJson(doc);
    return ReportModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'property_id': propertyId,
      'reason': reason.name,
      'details': details,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}

/// Office Model
class OfficeModel {
  final String id;
  final String name;
  final String? nameEn;
  final String ownerId;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String phone;
  final String? whatsapp;
  final String? email;
  final String? website;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int totalReviews;
  final int totalProperties;
  final int totalFollowers;
  final List<String> employeeIds;
  final SubscriptionTier subscriptionTier;
  final bool verified;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OfficeModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.ownerId,
    this.description,
    this.logoUrl,
    this.coverUrl,
    required this.phone,
    this.whatsapp,
    this.email,
    this.website,
    this.address,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalProperties = 0,
    this.totalFollowers = 0,
    this.employeeIds = const [],
    this.subscriptionTier = SubscriptionTier.free,
    this.verified = false,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> data) {
    return OfficeModel(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      nameEn: data['name_en'] ?? data['nameEn'],
      ownerId: data['owner_id'] ?? data['ownerId'] ?? '',
      description: data['description'],
      logoUrl: data['logo_url'] ?? data['logoUrl'],
      coverUrl: data['cover_url'] ?? data['coverUrl'],
      phone: data['phone'] ?? '',
      whatsapp: data['whatsapp'],
      email: data['email'],
      website: data['website'],
      address: data['address'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['total_reviews'] ?? data['totalReviews'] ?? 0,
      totalProperties: data['total_properties'] ?? data['totalProperties'] ?? 0,
      totalFollowers: data['total_followers'] ?? data['totalFollowers'] ?? 0,
      employeeIds: List<String>.from(data['employee_ids'] ?? data['employeeIds'] ?? []),
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (e) => e.name == (data['subscription_tier'] ?? data['subscriptionTier']),
        orElse: () => SubscriptionTier.free,
      ),
      verified: data['verified'] ?? false,
      active: data['active'] ?? true,
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
      updatedAt: _parseDate(data['updated_at'] ?? data['updatedAt']),
    );
  }

  factory OfficeModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return OfficeModel.fromJson(doc);
    return OfficeModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'owner_id': ownerId,
      'description': description,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'website': website,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_properties': totalProperties,
      'total_followers': totalFollowers,
      'employee_ids': employeeIds,
      'subscription_tier': subscriptionTier.name,
      'verified': verified,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}

/// Banner Model
class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? actionUrl;
  final String? propertyId;
  final int order;
  final bool active;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.actionUrl,
    this.propertyId,
    this.order = 0,
    this.active = true,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> data) {
    return BannerModel(
      id: data['id']?.toString() ?? '',
      imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
      title: data['title'],
      subtitle: data['subtitle'],
      actionUrl: data['action_url'] ?? data['actionUrl'],
      propertyId: data['property_id'] ?? data['propertyId'],
      order: data['display_order'] ?? data['order'] ?? 0,
      active: data['active'] ?? true,
      startDate: data['start_date'] != null || data['startDate'] != null
          ? _parseDate(data['start_date'] ?? data['startDate'])
          : null,
      endDate: data['end_date'] != null || data['endDate'] != null
          ? _parseDate(data['end_date'] ?? data['endDate'])
          : null,
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  factory BannerModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return BannerModel.fromJson(doc);
    return BannerModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'action_url': actionUrl,
      'property_id': propertyId,
      'display_order': order,
      'active': active,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}

/// Subscription Model
class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final double price;
  final PaymentMethod paymentMethod;
  final String status; // active, expired, cancelled
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.tier,
    required this.price,
    required this.paymentMethod,
    this.status = 'active',
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> data) {
    return SubscriptionModel(
      id: data['id']?.toString() ?? '',
      userId: data['user_id'] ?? data['userId'] ?? '',
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == data['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      price: (data['price'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (data['payment_method'] ?? data['paymentMethod']),
        orElse: () => PaymentMethod.fawry,
      ),
      status: data['status'] ?? 'active',
      startDate: _parseDate(data['start_date'] ?? data['startDate']),
      endDate: _parseDate(data['end_date'] ?? data['endDate']),
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  factory SubscriptionModel.fromFirestore(dynamic doc) {
    if (doc is Map<String, dynamic>) return SubscriptionModel.fromJson(doc);
    return SubscriptionModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tier': tier.name,
      'price': price,
      'payment_method': paymentMethod.name,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
}


/// Property Filter Model for search
class PropertyFilterModel {
  final PropertyType? type;
  final PropertyPurpose? purpose;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int? minRooms;
  final int? maxRooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minFloor;
  final int? maxFloor;
  final FinishingType? finishing;
  final bool? furnished;
  final bool? elevator;
  final bool? garage;
  final bool? gas;
  final bool? garden;
  final bool? pool;
  final bool? security;
  final bool? installmentAvailable;
  final FacingDirection? facing;
  final int? yearBuilt;
  final String? areaName;
  final String? street;
  final String? project;
  final double? nearLat;
  final double? nearLng;
  final double? nearRadius;
  final SortBy sortBy;

  const PropertyFilterModel({
    this.type,
    this.purpose,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.minRooms,
    this.maxRooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minFloor,
    this.maxFloor,
    this.finishing,
    this.furnished,
    this.elevator,
    this.garage,
    this.gas,
    this.garden,
    this.pool,
    this.security,
    this.installmentAvailable,
    this.facing,
    this.yearBuilt,
    this.areaName,
    this.street,
    this.project,
    this.nearLat,
    this.nearLng,
    this.nearRadius,
    this.sortBy = SortBy.newest,
  });

  bool get hasActiveFilters =>
      type != null ||
      purpose != null ||
      minPrice != null ||
      maxPrice != null ||
      minArea != null ||
      maxArea != null ||
      minRooms != null ||
      finishing != null ||
      furnished != null ||
      elevator != null ||
      garage != null ||
      areaName != null;

  PropertyFilterModel copyWith({
    PropertyType? type,
    PropertyPurpose? purpose,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? minRooms,
    int? maxRooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minFloor,
    int? maxFloor,
    FinishingType? finishing,
    bool? furnished,
    bool? elevator,
    bool? garage,
    bool? gas,
    bool? garden,
    bool? pool,
    bool? security,
    bool? installmentAvailable,
    FacingDirection? facing,
    int? yearBuilt,
    String? areaName,
    String? street,
    String? project,
    double? nearLat,
    double? nearLng,
    double? nearRadius,
    SortBy? sortBy,
  }) {
    return PropertyFilterModel(
      type: type ?? this.type,
      purpose: purpose ?? this.purpose,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      minRooms: minRooms ?? this.minRooms,
      maxRooms: maxRooms ?? this.maxRooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minFloor: minFloor ?? this.minFloor,
      maxFloor: maxFloor ?? this.maxFloor,
      finishing: finishing ?? this.finishing,
      furnished: furnished ?? this.furnished,
      elevator: elevator ?? this.elevator,
      garage: garage ?? this.garage,
      gas: gas ?? this.gas,
      garden: garden ?? this.garden,
      pool: pool ?? this.pool,
      security: security ?? this.security,
      installmentAvailable: installmentAvailable ?? this.installmentAvailable,
      facing: facing ?? this.facing,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      areaName: areaName ?? this.areaName,
      street: street ?? this.street,
      project: project ?? this.project,
      nearLat: nearLat ?? this.nearLat,
      nearLng: nearLng ?? this.nearLng,
      nearRadius: nearRadius ?? this.nearRadius,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static const PropertyFilterModel empty = PropertyFilterModel();
}
