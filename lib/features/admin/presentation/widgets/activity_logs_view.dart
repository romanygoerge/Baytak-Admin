import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Activity logs viewer
class ActivityLogsView extends ConsumerWidget {
  const ActivityLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logsAsync = ref.watch(activityLogsStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('سجلات النظام', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('عرض جميع الأنشطة والعمليات الإدارية', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (logs) {
              final sorted = [...logs]..sort((a, b) {
                  final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
                  final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
                  return dateB.compareTo(dateA);
                });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSectionHeader(title: 'السجلات (${sorted.length})', accentColor: const Color(0xFF64748B)),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لا توجد سجلات بعد',
                    columns: const [
                      DataColumn(label: Text('الإجراء')),
                      DataColumn(label: Text('النوع')),
                      DataColumn(label: Text('التفاصيل')),
                      DataColumn(label: Text('التاريخ والوقت')),
                    ],
                    rows: sorted.map((log) {
                      return DataRow(cells: [
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_actionIcon(log['action'] ?? ''), size: 16, color: _actionColor(log['action'] ?? '')),
                            const SizedBox(width: 8),
                            Text(_actionAr(log['action'] ?? ''), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        )),
                        DataCell(AdminStatusChip(
                          status: log['target_type'] ?? 'system',
                          customMap: const {
                            'user': (AppColors.info, 'مستخدم'),
                            'property': (Color(0xFF6366F1), 'عقار'),
                            'office': (AppColors.warning, 'مكتب'),
                            'report': (AppColors.error, 'بلاغ'),
                            'subscription': (Color(0xFF8B5CF6), 'اشتراك'),
                            'notification': (Color(0xFF0EA5E9), 'إشعار'),
                            'area': (Color(0xFFEC4899), 'منطقة'),
                            'system': (AppColors.textHint, 'نظام'),
                          },
                        )),
                        DataCell(SizedBox(width: 220, child: Text(log['details'] ?? '-', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))),
                        DataCell(Text(_formatDateTime(log['created_at']), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                      ]);
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _actionIcon(String action) {
    if (action.contains('delete')) return Icons.delete_rounded;
    if (action.contains('block')) return Icons.block_rounded;
    if (action.contains('unblock')) return Icons.lock_open_rounded;
    if (action.contains('role')) return Icons.admin_panel_settings_rounded;
    if (action.contains('approve') || action.contains('resolve') || action.contains('active')) return Icons.check_circle_rounded;
    if (action.contains('reject') || action.contains('dismiss')) return Icons.cancel_rounded;
    if (action.contains('featured')) return Icons.star_rounded;
    if (action.contains('notification')) return Icons.notifications_rounded;
    if (action.contains('area')) return Icons.location_city_rounded;
    if (action.contains('office')) return Icons.business_rounded;
    if (action.contains('subscription')) return Icons.workspace_premium_rounded;
    return Icons.history_rounded;
  }

  Color _actionColor(String action) {
    if (action.contains('delete')) return AppColors.error;
    if (action.contains('block')) return AppColors.error;
    if (action.contains('unblock')) return AppColors.success;
    if (action.contains('approve') || action.contains('resolve') || action.contains('active')) return AppColors.success;
    if (action.contains('reject') || action.contains('dismiss')) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _actionAr(String action) {
    const map = {
      'change_role': 'تغيير الصلاحية',
      'block_user': 'حظر مستخدم',
      'unblock_user': 'إلغاء حظر',
      'delete_user': 'حذف مستخدم',
      'update_property_status': 'تحديث حالة عقار',
      'toggle_featured': 'تثبيت/إلغاء تثبيت',
      'delete_property': 'حذف عقار',
      'toggle_office_verified': 'اعتماد/إلغاء مكتب',
      'toggle_office_active': 'تفعيل/تعليق مكتب',
      'resolve_report': 'معالجة بلاغ',
      'dismiss_report': 'رفض بلاغ',
      'update_subscription': 'تحديث اشتراك',
      'send_notification': 'إرسال إشعار',
      'add_area': 'إضافة منطقة',
      'update_area': 'تعديل منطقة',
      'delete_area': 'حذف منطقة',
    };
    return map[action] ?? action;
  }

  String _formatDateTime(dynamic d) {
    if (d == null) return '';
    final date = DateTime.tryParse(d.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
