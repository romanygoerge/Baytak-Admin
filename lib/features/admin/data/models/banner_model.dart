class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? emoji;
  final String ctaText;
  final String targetType; // 'category', 'purpose', 'featured', 'property', 'route', 'url'
  final String? targetValue; // e.g. 'apartment', 'sale', 'rent', property UUID, custom route
  final int gradientIndex;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.emoji,
    this.ctaText = 'تصفح الآن',
    this.targetType = 'category',
    this.targetValue,
    this.gradientIndex = 0,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      emoji: json['emoji']?.toString(),
      ctaText: json['cta_text']?.toString() ?? json['ctaText']?.toString() ?? 'تصفح الآن',
      targetType: json['target_type']?.toString() ?? json['targetType']?.toString() ?? 'category',
      targetValue: json['target_value']?.toString() ?? json['targetValue']?.toString(),
      gradientIndex: (json['gradient_index'] ?? json['gradientIndex'] ?? 0) is int
          ? (json['gradient_index'] ?? json['gradientIndex'] ?? 0) as int
          : int.tryParse((json['gradient_index'] ?? json['gradientIndex'] ?? 0).toString()) ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      sortOrder: (json['sort_order'] ?? json['sortOrder'] ?? 0) is int
          ? (json['sort_order'] ?? json['sortOrder'] ?? 0) as int
          : int.tryParse((json['sort_order'] ?? json['sortOrder'] ?? 0).toString()) ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'emoji': emoji,
      'cta_text': ctaText,
      'target_type': targetType,
      'target_value': targetValue,
      'gradient_index': gradientIndex,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? emoji,
    String? ctaText,
    String? targetType,
    String? targetValue,
    int? gradientIndex,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      emoji: emoji ?? this.emoji,
      ctaText: ctaText ?? this.ctaText,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Fallback initial banners
final List<BannerModel> defaultHomeBanners = [
  BannerModel(
    id: 'default_1',
    title: 'اكتشف أفضل العروض',
    subtitle: 'شقق وفيلات بأسعار مميزة في مدينة السادات',
    emoji: '🏠',
    ctaText: 'تصفح الآن',
    targetType: 'featured',
    gradientIndex: 0,
    sortOrder: 1,
  ),
  BannerModel(
    id: 'default_2',
    title: 'عقارات للإيجار',
    subtitle: 'أفضل المواقع في جميع المناطق',
    emoji: '🔑',
    ctaText: 'اكتشف المزيد',
    targetType: 'purpose',
    targetValue: 'rent',
    gradientIndex: 1,
    sortOrder: 2,
  ),
  BannerModel(
    id: 'default_3',
    title: 'أراضي للبيع',
    subtitle: 'فرص استثمارية واعدة ومواقع متميزة',
    emoji: '🌍',
    ctaText: 'تصفح الآن',
    targetType: 'category',
    targetValue: 'land',
    gradientIndex: 2,
    sortOrder: 3,
  ),
];
