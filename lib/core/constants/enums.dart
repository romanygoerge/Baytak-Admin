import 'package:flutter/material.dart';

// All enums used across the Baytak application

// ─── Property Enums ────────────────────────────────────────────────

enum PropertyType {
  apartment,
  villa,
  duplex,
  penthouse,
  studio,
  shop,
  office,
  clinic,
  land,
  warehouse,
  factory,
  farm,
  commercial,
  administrative;

  IconData get iconData => switch (this) {
    PropertyType.apartment => Icons.apartment_rounded,
    PropertyType.villa => Icons.villa_rounded,
    PropertyType.duplex => Icons.home_work_rounded,
    PropertyType.penthouse => Icons.location_city_rounded,
    PropertyType.studio => Icons.bed_rounded,
    PropertyType.shop => Icons.storefront_rounded,
    PropertyType.office => Icons.business_center_rounded,
    PropertyType.clinic => Icons.local_hospital_rounded,
    PropertyType.land => Icons.landscape_rounded,
    PropertyType.warehouse => Icons.warehouse_rounded,
    PropertyType.factory => Icons.precision_manufacturing_rounded,
    PropertyType.farm => Icons.agriculture_rounded,
    PropertyType.commercial => Icons.store_rounded,
    PropertyType.administrative => Icons.corporate_fare_rounded,
  };

  String get nameAr => switch (this) {
    PropertyType.apartment => 'شقة',
    PropertyType.villa => 'فيلا',
    PropertyType.duplex => 'دوبلكس',
    PropertyType.penthouse => 'بنتهاوس',
    PropertyType.studio => 'استوديو',
    PropertyType.shop => 'محل',
    PropertyType.office => 'مكتب',
    PropertyType.clinic => 'عيادة',
    PropertyType.land => 'أرض',
    PropertyType.warehouse => 'مخزن',
    PropertyType.factory => 'مصنع',
    PropertyType.farm => 'مزرعة',
    PropertyType.commercial => 'تجاري',
    PropertyType.administrative => 'إداري',
  };

  String get nameEn => switch (this) {
    PropertyType.apartment => 'Apartment',
    PropertyType.villa => 'Villa',
    PropertyType.duplex => 'Duplex',
    PropertyType.penthouse => 'Penthouse',
    PropertyType.studio => 'Studio',
    PropertyType.shop => 'Shop',
    PropertyType.office => 'Office',
    PropertyType.clinic => 'Clinic',
    PropertyType.land => 'Land',
    PropertyType.warehouse => 'Warehouse',
    PropertyType.factory => 'Factory',
    PropertyType.farm => 'Farm',
    PropertyType.commercial => 'Commercial',
    PropertyType.administrative => 'Administrative',
  };

  String get icon => switch (this) {
    PropertyType.apartment => '🏢',
    PropertyType.villa => '🏡',
    PropertyType.duplex => '🏘️',
    PropertyType.penthouse => '🏙️',
    PropertyType.studio => '🛏️',
    PropertyType.shop => '🏪',
    PropertyType.office => '🏛️',
    PropertyType.clinic => '🏥',
    PropertyType.land => '🌍',
    PropertyType.warehouse => '🏭',
    PropertyType.factory => '🏗️',
    PropertyType.farm => '🌾',
    PropertyType.commercial => '🏬',
    PropertyType.administrative => '🏢',
  };
}

enum PropertyPurpose {
  sale,
  rent;

  String get nameAr => switch (this) {
    PropertyPurpose.sale => 'للبيع',
    PropertyPurpose.rent => 'للإيجار',
  };

  String get nameEn => switch (this) {
    PropertyPurpose.sale => 'For Sale',
    PropertyPurpose.rent => 'For Rent',
  };
}

enum PropertyStatus {
  draft,
  pending,
  active,
  rejected,
  sold,
  rented,
  expired;

  String get nameAr => switch (this) {
    PropertyStatus.draft => 'مسودة',
    PropertyStatus.pending => 'قيد المراجعة',
    PropertyStatus.active => 'نشط',
    PropertyStatus.rejected => 'مرفوض',
    PropertyStatus.sold => 'تم البيع',
    PropertyStatus.rented => 'تم التأجير',
    PropertyStatus.expired => 'منتهي',
  };

  String get nameEn => switch (this) {
    PropertyStatus.draft => 'Draft',
    PropertyStatus.pending => 'Pending',
    PropertyStatus.active => 'Active',
    PropertyStatus.rejected => 'Rejected',
    PropertyStatus.sold => 'Sold',
    PropertyStatus.rented => 'Rented',
    PropertyStatus.expired => 'Expired',
  };
}

enum FinishingType {
  none,
  semi,
  full,
  luxury,
  ultraLuxury;

  String get nameAr => switch (this) {
    FinishingType.none => 'بدون تشطيب',
    FinishingType.semi => 'نصف تشطيب',
    FinishingType.full => 'تشطيب كامل',
    FinishingType.luxury => 'تشطيب فاخر',
    FinishingType.ultraLuxury => 'سوبر لوكس',
  };

  String get nameEn => switch (this) {
    FinishingType.none => 'No Finishing',
    FinishingType.semi => 'Semi Finished',
    FinishingType.full => 'Fully Finished',
    FinishingType.luxury => 'Luxury',
    FinishingType.ultraLuxury => 'Ultra Luxury',
  };
}

enum FacingDirection {
  north,
  south,
  east,
  west,
  northeast,
  northwest,
  southeast,
  southwest;

  String get nameAr => switch (this) {
    FacingDirection.north => 'شمال',
    FacingDirection.south => 'جنوب',
    FacingDirection.east => 'شرق',
    FacingDirection.west => 'غرب',
    FacingDirection.northeast => 'شمال شرق',
    FacingDirection.northwest => 'شمال غرب',
    FacingDirection.southeast => 'جنوب شرق',
    FacingDirection.southwest => 'جنوب غرب',
  };

  String get nameEn => switch (this) {
    FacingDirection.north => 'North',
    FacingDirection.south => 'South',
    FacingDirection.east => 'East',
    FacingDirection.west => 'West',
    FacingDirection.northeast => 'Northeast',
    FacingDirection.northwest => 'Northwest',
    FacingDirection.southeast => 'Southeast',
    FacingDirection.southwest => 'Southwest',
  };
}

// ─── User Enums ─────────────────────────────────────────────────────

enum UserRole {
  user,
  officeOwner,
  officeEmployee,
  admin,
  superAdmin,
  moderator,
  support,
  marketing,
  contentManager;

  String get nameAr => switch (this) {
    UserRole.user => 'مستخدم',
    UserRole.officeOwner => 'صاحب مكتب',
    UserRole.officeEmployee => 'موظف مكتب',
    UserRole.admin => 'مدير',
    UserRole.superAdmin => 'مدير عام',
    UserRole.moderator => 'مشرف',
    UserRole.support => 'دعم فني',
    UserRole.marketing => 'تسويق',
    UserRole.contentManager => 'مدير محتوى',
  };

  bool get isAdmin => this == UserRole.admin || this == UserRole.superAdmin;
  bool get isStaff => isAdmin || this == UserRole.moderator || this == UserRole.support || this == UserRole.marketing || this == UserRole.contentManager;
  bool get isOffice => this == UserRole.officeOwner || this == UserRole.officeEmployee;
}

enum AuthProvider {
  phone,
  google,
  apple,
  email,
}

// ─── Chat Enums ─────────────────────────────────────────────────────

enum MessageType {
  text,
  image,
  video,
  file,
  location,
  voice,
  property;

  String get nameAr => switch (this) {
    MessageType.text => 'نص',
    MessageType.image => 'صورة',
    MessageType.video => 'فيديو',
    MessageType.file => 'ملف',
    MessageType.location => 'موقع',
    MessageType.voice => 'رسالة صوتية',
    MessageType.property => 'عقار',
  };
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed;
}

// ─── Subscription Enums ─────────────────────────────────────────────

enum SubscriptionTier {
  free,
  silver,
  gold,
  platinum;

  String get nameAr => switch (this) {
    SubscriptionTier.free => 'مجاني',
    SubscriptionTier.silver => 'الفضية',
    SubscriptionTier.gold => 'الذهبية',
    SubscriptionTier.platinum => 'البلاتينية',
  };

  String get nameEn => switch (this) {
    SubscriptionTier.free => 'Free',
    SubscriptionTier.silver => 'Silver',
    SubscriptionTier.gold => 'Gold',
    SubscriptionTier.platinum => 'Platinum',
  };
}

enum PaymentMethod {
  visa,
  mastercard,
  applePay,
  googlePay,
  fawry,
  vodafoneCash,
  instaPay;

  String get nameAr => switch (this) {
    PaymentMethod.visa => 'فيزا',
    PaymentMethod.mastercard => 'ماستركارد',
    PaymentMethod.applePay => 'Apple Pay',
    PaymentMethod.googlePay => 'Google Pay',
    PaymentMethod.fawry => 'فوري',
    PaymentMethod.vodafoneCash => 'فودافون كاش',
    PaymentMethod.instaPay => 'انستاباي',
  };
}

// ─── Report Enums ───────────────────────────────────────────────────

enum ReportReason {
  spam,
  fake,
  inappropriate,
  scam,
  duplicate,
  wrongCategory,
  wrongPrice,
  other;

  String get nameAr => switch (this) {
    ReportReason.spam => 'محتوى مزعج',
    ReportReason.fake => 'إعلان مزيف',
    ReportReason.inappropriate => 'محتوى غير لائق',
    ReportReason.scam => 'احتيال',
    ReportReason.duplicate => 'إعلان مكرر',
    ReportReason.wrongCategory => 'تصنيف خاطئ',
    ReportReason.wrongPrice => 'سعر غير صحيح',
    ReportReason.other => 'أخرى',
  };
}

// ─── Notification Enums ─────────────────────────────────────────────

enum NotificationType {
  message,
  propertyAdded,
  propertyApproved,
  propertyRejected,
  propertyUpdated,
  offer,
  subscription,
  system;

  String get nameAr => switch (this) {
    NotificationType.message => 'رسالة جديدة',
    NotificationType.propertyAdded => 'إعلان جديد',
    NotificationType.propertyApproved => 'تم قبول الإعلان',
    NotificationType.propertyRejected => 'تم رفض الإعلان',
    NotificationType.propertyUpdated => 'تم تعديل الإعلان',
    NotificationType.offer => 'عرض خاص',
    NotificationType.subscription => 'اشتراك',
    NotificationType.system => 'إشعار النظام',
  };
}

// ─── Sort Enums ─────────────────────────────────────────────────────

enum SortBy {
  newest,
  oldest,
  priceHighToLow,
  priceLowToHigh,
  areaHighToLow,
  areaLowToHigh,
  mostViewed,
  nearest;

  String get nameAr => switch (this) {
    SortBy.newest => 'الأحدث',
    SortBy.oldest => 'الأقدم',
    SortBy.priceHighToLow => 'السعر: الأعلى أولاً',
    SortBy.priceLowToHigh => 'السعر: الأقل أولاً',
    SortBy.areaHighToLow => 'المساحة: الأكبر أولاً',
    SortBy.areaLowToHigh => 'المساحة: الأصغر أولاً',
    SortBy.mostViewed => 'الأكثر مشاهدة',
    SortBy.nearest => 'الأقرب',
  };
}
