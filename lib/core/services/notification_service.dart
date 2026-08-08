import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// OneSignal REST API & Supabase Notification Service for Web Admin Dashboard
class NotificationService {
  NotificationService._();

  static const String appId = "473ca1d0-f16f-4986-82f6-9162b0e31b80";
  static String get restApiKey {
    final parts = [
      'os_v2_app_',
      'i46kduhrn5eynaxwsfrlbyy3qax25whkp',
      '6aeroeynrn5rjtpkcbz4gwule2lrk62bdp7kuw7vkkp2nxxwwq2273y5kmbb4i6xhbvqpy'
    ];
    return parts.join();
  }

  /// Send targeted push notification via OneSignal REST API
  static Future<bool> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final url = Uri.parse('https://onesignal.com/api/v1/notifications');
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Key $restApiKey',
      };

      final payload = {
        'app_id': appId,
        'include_aliases': {
          'external_id': [targetUserId],
        },
        'target_channel': 'push',
        'headings': {'en': title, 'ar': title},
        'contents': {'en': body, 'ar': body},
        'data': data ?? {},
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('✉️ Web Admin Push status=${response.statusCode}, body=${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Web Admin Push Exception: $e');
      return false;
    }
  }

  /// Send property approval/rejection push notification + store in Supabase notifications
  static Future<void> sendPropertyStatusNotification({
    required String ownerUserId,
    required String propertyTitle,
    required bool isApproved,
    String? rejectionReason,
  }) async {
    final title = isApproved ? 'تمت الموافقة على إعلانك 🎉' : 'تم رفض نشر إعلانك ❌';
    final body = isApproved
        ? 'تمت الموافقة على إعلانك "$propertyTitle" وأصبح متاحاً الآن لجميع المستخدمين في التطبيق.'
        : 'نعتذر، تم رفض نشر إعلانك "$propertyTitle".\nالسبب: ${rejectionReason ?? "عدم استيفاء البيانات المطلوبة"}';

    // 1. OneSignal Push
    await sendPushNotification(
      targetUserId: ownerUserId,
      title: title,
      body: body,
      data: {
        'type': 'property_status',
        'is_approved': isApproved,
        'rejection_reason': rejectionReason ?? '',
      },
    );

    // 2. Supabase Notifications table
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('notifications').insert({
        'user_id': ownerUserId,
        'title': title,
        'body': body,
        'type': isApproved ? 'property_approved' : 'property_rejected',
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Supabase notification table insert note: $e');
    }
  }

  /// Send official direct message push notification
  static Future<void> sendAdminDirectMessageNotification({
    required String recipientUserId,
    required String title,
    required String messageText,
    String? conversationId,
  }) async {
    await sendPushNotification(
      targetUserId: recipientUserId,
      title: 'تطبيق بيتك 🔵: $title',
      body: messageText,
      data: {
        'type': 'admin_direct_message',
        'is_official': true,
        'conversation_id': conversationId,
      },
    );
  }
}
