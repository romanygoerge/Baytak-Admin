import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin Service - Handles all admin CRUD operations with Supabase
class AdminService {
  final SupabaseClient _supabase;

  AdminService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ─── Streams (Real-time with REST Fallback) ──────────────────────

  Stream<List<Map<String, dynamic>>> streamTable(String table) async* {
    // 1. Immediate fetch via REST API
    try {
      final initialData = await fetchAll(table);
      yield initialData;
    } catch (e) {
      debugPrint('Initial REST fetch error for $table: $e');
      yield [];
    }

    // 2. Attempt Realtime stream; if Realtime is disabled or throws error, catch & fallback to polling
    bool realtimeConnected = false;
    try {
      final stream = _supabase.from(table).stream(primaryKey: ['id']);
      await for (final data in stream) {
        realtimeConnected = true;
        yield data;
      }
    } catch (e) {
      debugPrint('Realtime stream disabled or failed for $table ($e). Switching to 5s polling.');
    }

    // 3. Fallback polling loop if Realtime stream failed or closed
    if (!realtimeConnected) {
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        try {
          final pollingData = await fetchAll(table);
          yield pollingData;
        } catch (e) {
          debugPrint('Polling error for $table: $e');
        }
      }
    }
  }

  // ─── Generic CRUD ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchAll(String table, {String orderBy = 'created_at', bool ascending = false, int? limit}) async {
    var query = _supabase.from(table).select().order(orderBy, ascending: ascending);
    if (limit != null) query = query.limit(limit);
    return await query;
  }

  Future<Map<String, dynamic>?> fetchById(String table, String id) async {
    return await _supabase.from(table).select().eq('id', id).maybeSingle();
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    await _supabase.from(table).insert(data);
  }

  Future<void> update(String table, String id, Map<String, dynamic> data) async {
    await _supabase.from(table).update(data).eq('id', id);
  }

  Future<void> delete(String table, String id) async {
    await _supabase.from(table).delete().eq('id', id);
  }

  SupabaseClient get supabase => _supabase;

  // ─── Count ───────────────────────────────────────────────────────

  Future<int> count(String table, {Map<String, dynamic>? filters}) async {
    try {
      var query = _supabase.from(table).select();
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }
      final result = await query;
      return result.length;
    } catch (e) {
      debugPrint('Error counting $table: $e');
      return 0;
    }
  }

  // ─── Users Management ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchUsers({String? search, String? roleFilter}) async {
    var query = _supabase.from('profiles').select();
    if (roleFilter != null && roleFilter.isNotEmpty) {
      query = query.eq('role', roleFilter);
    }
    final result = await query.order('created_at', ascending: false);
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      return List<Map<String, dynamic>>.from(result).where((u) {
        return (u['name'] ?? '').toString().toLowerCase().contains(s) ||
            (u['email'] ?? '').toString().toLowerCase().contains(s) ||
            (u['phone'] ?? '').toString().contains(s);
      }).toList();
    }
    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _supabase.from('profiles').update({'role': role, 'updated_at': DateTime.now().toIso8601String()}).eq('id', userId);
    await _logActivity('change_role', 'user', userId, 'تغيير الصلاحية إلى $role');
  }

  Future<void> toggleUserBlock(String userId, bool blocked) async {
    await _supabase.from('profiles').update({'blocked': blocked, 'updated_at': DateTime.now().toIso8601String()}).eq('id', userId);
    await _logActivity(blocked ? 'block_user' : 'unblock_user', 'user', userId, blocked ? 'حظر المستخدم' : 'إلغاء حظر المستخدم');
  }

  Future<void> deleteUser(String userId) async {
    await _supabase.from('profiles').delete().eq('id', userId);
    await _logActivity('delete_user', 'user', userId, 'حذف حساب المستخدم');
  }

  // ─── Properties Management ───────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchProperties({String? statusFilter, String? search}) async {
    var query = _supabase.from('properties').select();
    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.eq('status', statusFilter);
    }
    final result = await query.order('created_at', ascending: false);
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      return List<Map<String, dynamic>>.from(result).where((p) {
        return (p['title'] ?? '').toString().toLowerCase().contains(s);
      }).toList();
    }
    return result;
  }

  Future<void> updatePropertyStatus(String propertyId, String status) async {
    await _supabase.from('properties').update({'status': status, 'updated_at': DateTime.now().toIso8601String()}).eq('id', propertyId);
    await _logActivity('update_property_status', 'property', propertyId, 'تغيير حالة العقار إلى $status');
  }

  Future<void> togglePropertyFeatured(String propertyId, bool featured) async {
    await _supabase.from('properties').update({'featured': featured, 'updated_at': DateTime.now().toIso8601String()}).eq('id', propertyId);
    await _logActivity('toggle_featured', 'property', propertyId, featured ? 'تثبيت العقار' : 'إلغاء تثبيت العقار');
  }

  Future<void> deleteProperty(String propertyId) async {
    await _supabase.from('properties').delete().eq('id', propertyId);
    await _logActivity('delete_property', 'property', propertyId, 'حذف العقار');
  }

  // ─── Offices Management ──────────────────────────────────────────

  Future<void> toggleOfficeVerified(String officeId, bool verified) async {
    await _supabase.from('offices').update({'verified': verified, 'updated_at': DateTime.now().toIso8601String()}).eq('id', officeId);
    await _logActivity('toggle_office_verified', 'office', officeId, verified ? 'اعتماد المكتب' : 'إلغاء اعتماد المكتب');
  }

  Future<void> toggleOfficeActive(String officeId, bool active) async {
    await _supabase.from('offices').update({'active': active, 'updated_at': DateTime.now().toIso8601String()}).eq('id', officeId);
    await _logActivity('toggle_office_active', 'office', officeId, active ? 'تفعيل المكتب' : 'تعليق المكتب');
  }

  // ─── Reports Management ──────────────────────────────────────────

  Future<void> resolveReport(String reportId, String adminNote, String adminId) async {
    await _supabase.from('reports').update({
      'status': 'resolved',
      'admin_note': adminNote,
      'resolved_by': adminId,
      'resolved_at': DateTime.now().toIso8601String(),
    }).eq('id', reportId);
    await _logActivity('resolve_report', 'report', reportId, 'معالجة البلاغ: $adminNote');
  }

  Future<void> dismissReport(String reportId) async {
    await _supabase.from('reports').update({'status': 'dismissed'}).eq('id', reportId);
    await _logActivity('dismiss_report', 'report', reportId, 'رفض البلاغ');
  }

  // ─── Subscriptions Management ────────────────────────────────────

  Future<void> updateSubscriptionStatus(String subscriptionId, String status) async {
    await _supabase.from('subscriptions').update({'status': status, 'updated_at': DateTime.now().toIso8601String()}).eq('id', subscriptionId);
    await _logActivity('update_subscription', 'subscription', subscriptionId, 'تغيير حالة الاشتراك إلى $status');
  }

  // ─── Notifications ───────────────────────────────────────────────

  Future<void> sendNotification({
    required String title,
    required String body,
    String? targetUserId,
    bool targetAll = false,
    required String sentBy,
  }) async {
    await _supabase.from('notifications').insert({
      'title': title,
      'body': body,
      'type': 'system',
      'user_id': targetUserId,
      'target_user_id': targetUserId,
      'target_all': targetAll,
      'sent_by': sentBy,
    });
    await _logActivity('send_notification', 'notification', targetUserId, 'إرسال إشعار: $title');
  }

  // ─── Areas Management ────────────────────────────────────────────

  Future<void> addArea(Map<String, dynamic> data) async {
    await _supabase.from('areas').insert(data);
    await _logActivity('add_area', 'area', null, 'إضافة منطقة: ${data['name']}');
  }

  Future<void> updateArea(String areaId, Map<String, dynamic> data) async {
    await _supabase.from('areas').update(data).eq('id', areaId);
    await _logActivity('update_area', 'area', areaId, 'تعديل منطقة');
  }

  Future<void> deleteArea(String areaId) async {
    await _supabase.from('areas').delete().eq('id', areaId);
    await _logActivity('delete_area', 'area', areaId, 'حذف منطقة');
  }

  // ─── Activity Logging ────────────────────────────────────────────

  Future<void> _logActivity(String action, String? targetType, String? targetId, String? details) async {
    try {
      final adminId = _supabase.auth.currentUser?.id;
      await _supabase.from('activity_logs').insert({
        'admin_id': adminId,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        'details': details,
      });
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }
}
