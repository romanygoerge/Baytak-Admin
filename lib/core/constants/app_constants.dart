// Baytak - Real Estate Platform for Sadat City
// Core Constants

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Baytak';
  static const String appNameAr = 'بيتك';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Real Estate Platform for Sadat City';

  // Location
  static const String defaultCity = 'مدينة السادات';
  static const String defaultCityEn = 'Sadat City';
  static const String defaultGovernorate = 'المنوفية';
  static const String defaultGovernorateEn = 'Menoufia';
  static const String defaultCountry = 'مصر';
  static const String defaultCountryEn = 'Egypt';
  static const double defaultLat = 30.3873;
  static const double defaultLng = 30.5271;
  static const double defaultZoom = 13.0;

  // Limits
  static const int maxImages = 30;
  static const int maxVideos = 5;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int pageSize = 20;
  static const int searchDebounceMs = 500;
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Cache
  static const Duration cacheDuration = Duration(hours: 1);
  static const String cacheBoxName = 'baytak_cache';
  static const String settingsBoxName = 'baytak_settings';
  static const String userBoxName = 'baytak_user';

  // Packages
  static const Map<String, Map<String, dynamic>> subscriptionPackages = {
    'free': {
      'nameAr': 'مجاني',
      'nameEn': 'Free',
      'adsLimit': 3,
      'adDuration': 30,
      'featured': false,
      'statistics': false,
      'support': false,
      'price': 0,
    },
    'silver': {
      'nameAr': 'الفضية',
      'nameEn': 'Silver',
      'adsLimit': 15,
      'adDuration': 60,
      'featured': true,
      'statistics': true,
      'support': false,
      'price': 199,
    },
    'gold': {
      'nameAr': 'الذهبية',
      'nameEn': 'Gold',
      'adsLimit': 50,
      'adDuration': 90,
      'featured': true,
      'statistics': true,
      'support': true,
      'price': 499,
    },
    'platinum': {
      'nameAr': 'البلاتينية',
      'nameEn': 'Platinum',
      'adsLimit': -1, // unlimited
      'adDuration': 180,
      'featured': true,
      'statistics': true,
      'support': true,
      'price': 999,
    },
  };
}
