import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Offices management screen
class OfficesManagement extends ConsumerWidget {
  const OfficesManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final officesAsync = ref.watch(officesStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إدارة المكاتب', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('إدارة المكاتب العقارية المسجلة', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          officesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (offices) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSectionHeader(title: 'المكاتب (${offices.length})', accentColor: AppColors.warning),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لا توجد مكاتب مسجلة',
                    columns: const [
                      DataColumn(label: Text('اسم المكتب')),
                      DataColumn(label: Text('الهاتف')),
                      DataColumn(label: Text('المنطقة')),
                      DataColumn(label: Text('التقييم')),
                      DataColumn(label: Text('معتمد')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('الإجراءات')),
                    ],
                    rows: offices.map((o) {
                      final verified = o['verified'] == true;
                      final active = o['active'] == true;
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 140, child: Text(o['name'] ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)))),
                        DataCell(Text(o['phone'] ?? '-', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(o['area'] ?? '-', style: const TextStyle(fontSize: 12))),
                        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded, color: AppColors.featured, size: 14),
                          const SizedBox(width: 2),
                          Text('${(o['rating'] ?? 0).toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ])),
                        DataCell(Icon(verified ? Icons.verified_rounded : Icons.remove_circle_outline_rounded, color: verified ? AppColors.success : AppColors.textHint, size: 20)),
                        DataCell(AdminStatusChip(status: active ? 'active' : 'suspended', customMap: const {
                          'active': (AppColors.success, 'نشط'),
                          'suspended': (AppColors.error, 'معلق'),
                        })),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(verified ? Icons.verified_rounded : Icons.verified_outlined, color: verified ? AppColors.textHint : AppColors.success, size: 18),
                              tooltip: verified ? 'إلغاء الاعتماد' : 'اعتماد',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async => await ref.read(adminServiceProvider).toggleOfficeVerified(o['id'], !verified),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: Icon(active ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, color: active ? AppColors.warning : AppColors.success, size: 18),
                              tooltip: active ? 'تعليق' : 'تفعيل',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async => await ref.read(adminServiceProvider).toggleOfficeActive(o['id'], !active),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                              tooltip: 'حذف',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async => await ref.read(adminServiceProvider).delete('offices', o['id']),
                            ),
                          ],
                        )),
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
}
