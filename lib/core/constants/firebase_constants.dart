// Firebase collection and document path constants

class FirebaseConstants {
  FirebaseConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String propertiesCollection = 'properties';
  static const String conversationsCollection = 'conversations';
  static const String messagesSubcollection = 'messages';
  static const String notificationsCollection = 'notifications';
  static const String favoritesCollection = 'favorites';
  static const String officesCollection = 'offices';
  static const String subscriptionsCollection = 'subscriptions';
  static const String paymentsCollection = 'payments';
  static const String reportsCollection = 'reports';
  static const String reviewsCollection = 'reviews';
  static const String bannersCollection = 'banners';
  static const String areasCollection = 'areas';
  static const String settingsCollection = 'settings';
  static const String analyticsCollection = 'analytics';
  static const String activityLogsCollection = 'activity_logs';

  // Storage paths
  static const String propertyImagesPath = 'properties/images';
  static const String propertyVideosPath = 'properties/videos';
  static const String propertyDocumentsPath = 'properties/documents';
  static const String profileImagesPath = 'users/profiles';
  static const String chatMediaPath = 'chat/media';
  static const String bannerImagesPath = 'banners';
  static const String officeImagesPath = 'offices';

  // Settings document IDs
  static const String appSettingsDoc = 'app_settings';
  static const String seoSettingsDoc = 'seo_settings';
}
