import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Subscriptions management screen
class SubscriptionsManagement extends ConsumerWidget {
  const SubscriptionsManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subsAsync = ref.watch(subscriptionsStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('باقات الاشتراك', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('إدارة اشتراكات المستخدمين والباقات', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          subsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (subs) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tier summary cards
                  _buildTierSummary(subs, isDark),
                  const SizedBox(height: 28),

                  AdminSectionHeader(title: 'الاشتراكات (${subs.length})', accentColor: const Color(0xFF8B5CF6)),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لا توجد اشتراكات',
                    columns: const [
                      DataColumn(label: Text('المستخدم')),
                      DataColumn(label: Text('الباقة')),
                      DataColumn(label: Text('المبلغ')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('تاريخ البدء')),
                      DataColumn(label: Text('تاريخ الانتهاء')),
                      DataColumn(label: Text('الإجراءات')),
                    ],
                    rows: subs.map((s) {
                      return DataRow(cells: [
                        DataCell(Text(s['user_id']?.toString().substring(0, 8) ?? '-', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                        DataCell(AdminStatusChip(
                          status: s['tier'] ?? 'free',
                          customMap: const {
                            'free': (AppColors.textHint, 'مجاني'),
                            'silver': (Color(0xFF94A3B8), 'فضي'),
                            'gold': (AppColors.warning, 'ذهبي'),
                            'platinum': (Color(0xFF8B5CF6), 'بلاتيني'),
                          },
                        )),
                        DataCell(Text('${s['amount'] ?? 0} ج.م', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataCell(AdminStatusChip(status: s['status'] ?? 'active')),
                        DataCell(Text(_formatDate(s['starts_at']), style: const TextStyle(fontSize: 12))),
                        DataCell(Text(_formatDate(s['expires_at']), style: const TextStyle(fontSize: 12))),
                        DataCell(PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 18),
                          onSelected: (status) async => await ref.read(adminServiceProvider).updateSubscriptionStatus(s['id'], status),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'active', child: Text('تفعيل', style: TextStyle(fontSize: 13))),
                            const PopupMenuItem(value: 'cancelled', child: Text('إلغاء', style: TextStyle(fontSize: 13))),
                            const PopupMenuItem(value: 'expired', child: Text('منتهي', style: TextStyle(fontSize: 13))),
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

  Widget _buildTierSummary(List<Map<String, dynamic>> subs, bool isDark) {
    final tiers = {'free': 0, 'silver': 0, 'gold': 0, 'platinum': 0};
    for (final s in subs) {
      final tier = s['tier']?.toString() ?? 'free';
      tiers[tier] = (tiers[tier] ?? 0) + 1;
    }

    final tierColors = {'free': AppColors.textHint, 'silver': const Color(0xFF94A3B8), 'gold': AppColors.warning, 'platinum': const Color(0xFF8B5CF6)};
    final tierNames = {'free': 'مجاني', 'silver': 'فضي', 'gold': 'ذهبي', 'platinum': 'بلاتيني'};
    final tierIcons = {'free': Icons.card_giftcard_rounded, 'silver': Icons.workspace_premium_outlined, 'gold': Icons.workspace_premium_rounded, 'platinum': Icons.diamond_rounded};

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        final items = tiers.entries.map((e) {
          final card = Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (tierColors[e.key] ?? AppColors.textHint).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(tierIcons[e.key] ?? Icons.star, color: tierColors[e.key], size: 28),
                const SizedBox(height: 8),
                Text('${e.value}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: tierColors[e.key])),
                const SizedBox(height: 4),
                Text(tierNames[e.key] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ],
            ),
          );
          return isWide ? Expanded(child: card) : SizedBox(width: (constraints.maxWidth - 12) / 2, child: card);
        }).toList();

        if (isWide) {
          return Row(children: items);
        }
        return Wrap(runSpacing: 8, children: items);
      },
    );
  }

  String _formatDate(dynamic d) {
    if (d == null) return '-';
    final date = DateTime.tryParse(d.toString());
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }
}
