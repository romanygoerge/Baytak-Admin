import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Payments log management screen
class PaymentsManagement extends ConsumerWidget {
  const PaymentsManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paymentsAsync = ref.watch(paymentsStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('سجل المدفوعات', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('عرض جميع المعاملات المالية', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (payments) {
              final totalCompleted = payments.where((p) => p['status'] == 'completed').fold<double>(0, (sum, p) => sum + ((p['amount'] ?? 0) as num).toDouble());
              final totalPending = payments.where((p) => p['status'] == 'pending').fold<double>(0, (sum, p) => sum + ((p['amount'] ?? 0) as num).toDouble());

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 700) {
                        return Row(
                          children: [
                            Expanded(child: _summaryCard('إجمالي الإيرادات', totalCompleted, AppColors.success, Icons.trending_up_rounded, isDark)),
                            const SizedBox(width: 16),
                            Expanded(child: _summaryCard('مدفوعات معلقة', totalPending, AppColors.warning, Icons.pending_rounded, isDark)),
                            const SizedBox(width: 16),
                            Expanded(child: _summaryCard('عدد المعاملات', payments.length.toDouble(), AppColors.info, Icons.receipt_long_rounded, isDark)),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _summaryCard('إجمالي الإيرادات', totalCompleted, AppColors.success, Icons.trending_up_rounded, isDark),
                          const SizedBox(height: 12),
                          _summaryCard('مدفوعات معلقة', totalPending, AppColors.warning, Icons.pending_rounded, isDark),
                          const SizedBox(height: 12),
                          _summaryCard('عدد المعاملات', payments.length.toDouble(), AppColors.info, Icons.receipt_long_rounded, isDark),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  AdminSectionHeader(title: 'المعاملات (${payments.length})', accentColor: AppColors.success),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لا توجد مدفوعات',
                    columns: const [
                      DataColumn(label: Text('المستخدم')),
                      DataColumn(label: Text('المبلغ')),
                      DataColumn(label: Text('طريقة الدفع')),
                      DataColumn(label: Text('الوصف')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('التاريخ')),
                    ],
                    rows: payments.map((p) {
                      return DataRow(cells: [
                        DataCell(Text(p['user_id']?.toString().substring(0, 8) ?? '-', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                        DataCell(Text('${p['amount'] ?? 0} ${p['currency'] ?? 'ج.م'}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary))),
                        DataCell(Text(_paymentMethodAr(p['payment_method'] ?? ''), style: const TextStyle(fontSize: 12))),
                        DataCell(SizedBox(width: 140, child: Text(p['description'] ?? '-', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))),
                        DataCell(AdminStatusChip(
                          status: p['status'] ?? 'pending',
                          customMap: const {
                            'completed': (AppColors.success, 'مكتمل'),
                            'pending': (AppColors.warning, 'معلق'),
                            'failed': (AppColors.error, 'فشل'),
                            'refunded': (Color(0xFF8B5CF6), 'مسترد'),
                          },
                        )),
                        DataCell(Text(_formatDate(p['created_at']), style: const TextStyle(fontSize: 12))),
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

  Widget _summaryCard(String title, double value, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}K' : value.toStringAsFixed(0), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _paymentMethodAr(String method) {
    const map = {'visa': 'فيزا', 'mastercard': 'ماستركارد', 'fawry': 'فوري', 'vodafoneCash': 'فودافون كاش', 'instaPay': 'انستاباي'};
    return map[method] ?? (method.isEmpty ? '-' : method);
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    final date = DateTime.tryParse(d.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
