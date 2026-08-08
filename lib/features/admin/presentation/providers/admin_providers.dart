import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_service.dart';

/// Singleton provider for AdminService
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

/// Stream providers for real-time data
final usersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('profiles');
});

final propertiesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('properties');
});

final officesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('offices');
});

final reportsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('reports');
});

final subscriptionsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('subscriptions');
});

final paymentsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('payments');
});

final areasStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('areas');
});

final notificationsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('notifications');
});

final activityLogsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminServiceProvider).streamTable('activity_logs');
});
