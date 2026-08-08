import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Reports management screen
class ReportsManagement extends ConsumerWidget {
  const ReportsManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportsAsync = ref.watch(reportsStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('البلاغات والشكاوى', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('معالجة البلاغات المقدمة من المستخدمين', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          reportsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (reports) {
              // Sort: pending first
              final sorted = [...reports]..sort((a, b) {
                  if (a['status'] == 'pending' && b['status'] != 'pending') return -1;
                  if (b['status'] == 'pending' && a['status'] != 'pending') return 1;
                  return 0;
                });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSectionHeader(title: 'البلاغات (${reports.length})', accentColor: AppColors.error),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لا توجد بلاغات 🎉',
                    columns: const [
                      DataColumn(label: Text('السبب')),
                      DataColumn(label: Text('التفاصيل')),
                      DataColumn(label: Text('النوع')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('التاريخ')),
                      DataColumn(label: Text('الإجراءات')),
                    ],
                    rows: sorted.map((r) {
                      final isPending = r['status'] == 'pending';
                      return DataRow(cells: [
                        DataCell(Text(_reasonAr(r['reason'] ?? ''), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataCell(SizedBox(width: 180, child: Text(r['description'] ?? '-', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))),
                        DataCell(AdminStatusChip(
                          status: r['reported_item_type'] ?? 'property',
                          customMap: const {
                            'property': (AppColors.info, 'عقار'),
                            'user': (AppColors.warning, 'مستخدم'),
                            'office': (Color(0xFF8B5CF6), 'مكتب'),
                          },
                        )),
                        DataCell(AdminStatusChip(status: r['status'] ?? 'pending')),
                        DataCell(Text(_formatDate(r['created_at']), style: const TextStyle(fontSize: 12))),
                        DataCell(isPending
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                                    tooltip: 'معالجة',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _showResolveDialog(context, ref, r),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, color: AppColors.textHint, size: 18),
                                    tooltip: 'رفض البلاغ',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async => await ref.read(adminServiceProvider).dismissReport(r['id']),
                                  ),
                                ],
                              )
                            : Text(r['admin_note'] ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
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

  void _showResolveDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> report) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('معالجة البلاغ', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'ملاحظات المعالجة...',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              final adminId = ref.read(adminServiceProvider).supabase.auth.currentUser?.id ?? '';
              await ref.read(adminServiceProvider).resolveReport(report['id'], noteController.text, adminId);
            },
            child: const Text('تم المعالجة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _reasonAr(String reason) {
    const map = {'spam': 'محتوى مزعج', 'fake': 'إعلان مزيف', 'inappropriate': 'محتوى غير لائق', 'scam': 'احتيال', 'duplicate': 'مكرر', 'wrongCategory': 'تصنيف خاطئ', 'wrongPrice': 'سعر خاطئ', 'other': 'أخرى'};
    return map[reason] ?? reason;
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    final date = DateTime.tryParse(d.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
