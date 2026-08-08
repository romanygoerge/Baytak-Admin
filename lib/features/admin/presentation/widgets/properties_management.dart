import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Properties management screen with approve/reject/feature/delete
class PropertiesManagement extends ConsumerStatefulWidget {
  const PropertiesManagement({super.key});

  @override
  ConsumerState<PropertiesManagement> createState() => _PropertiesManagementState();
}

class _PropertiesManagementState extends ConsumerState<PropertiesManagement> {
  String _search = '';
  String _statusFilter = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final propsAsync = ref.watch(propertiesStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إدارة العقارات', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('مراجعة وإدارة الإعلانات العقارية', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          // Filters
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'بحث بعنوان العقار...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintStyle: const TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              _chip('الكل', '', isDark),
              _chip('قيد المراجعة', 'pending', isDark),
              _chip('نشط', 'active', isDark),
              _chip('مرفوض', 'rejected', isDark),
              _chip('تم البيع', 'sold', isDark),
              _chip('تم التأجير', 'rented', isDark),
            ],
          ),
          const SizedBox(height: 24),

          propsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (props) {
              var filtered = props.toList();
              if (_statusFilter.isNotEmpty) {
                filtered = filtered.where((p) => p['status'] == _statusFilter).toList();
              }
              if (_search.isNotEmpty) {
                final s = _search.toLowerCase();
                filtered = filtered.where((p) => (p['title'] ?? '').toString().toLowerCase().contains(s)).toList();
              }
              // Sort: pending first
              filtered.sort((a, b) {
                if (a['status'] == 'pending' && b['status'] != 'pending') return -1;
                if (b['status'] == 'pending' && a['status'] != 'pending') return 1;
                return 0;
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSectionHeader(title: 'العقارات (${filtered.length})', accentColor: const Color(0xFF6366F1)),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لا توجد عقارات',
                    columns: const [
                      DataColumn(label: Text('العنوان')),
                      DataColumn(label: Text('النوع')),
                      DataColumn(label: Text('الغرض')),
                      DataColumn(label: Text('السعر')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('مميز')),
                      DataColumn(label: Text('الإجراءات')),
                    ],
                    rows: filtered.map((p) {
                      final isFeatured = p['featured'] == true;
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 180, child: Text(p['title'] ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)))),
                        DataCell(Text(_typeAr(p['type'] ?? ''), style: const TextStyle(fontSize: 12))),
                        DataCell(AdminStatusChip(
                          status: p['purpose'] ?? 'sale',
                          customMap: const {
                            'sale': (AppColors.forSale, 'للبيع'),
                            'rent': (AppColors.forRent, 'للإيجار'),
                          },
                        )),
                        DataCell(Text('${_formatPrice(p['price'])} ج.م', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12))),
                        DataCell(AdminStatusChip(status: p['status'] ?? 'pending')),
                        DataCell(Icon(
                          isFeatured ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFeatured ? AppColors.featured : AppColors.textHint,
                          size: 20,
                        )),
                        DataCell(_buildActions(p)),
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

  Widget _chip(String label, String value, bool isDark) {
    final sel = _statusFilter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 12, color: sel ? Colors.white : null)),
      selected: sel,
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      backgroundColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
    );
  }

  Widget _buildActions(Map<String, dynamic> prop) {
    final status = prop['status'] ?? 'pending';
    final isFeatured = prop['featured'] == true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == 'pending') ...[
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
            tooltip: 'موافقة',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async => await ref.read(adminServiceProvider).updatePropertyStatus(prop['id'], 'active'),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
            tooltip: 'رفض',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async => await ref.read(adminServiceProvider).updatePropertyStatus(prop['id'], 'rejected'),
          ),
          const SizedBox(width: 6),
        ],
        IconButton(
          icon: Icon(isFeatured ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.featured, size: 20),
          tooltip: isFeatured ? 'إلغاء التثبيت' : 'تثبيت',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async => await ref.read(adminServiceProvider).togglePropertyFeatured(prop['id'], !isFeatured),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
          tooltip: 'حذف',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _confirmDelete(prop),
        ),
      ],
    );
  }

  void _confirmDelete(Map<String, dynamic> prop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف العقار', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('هل أنت متأكد من حذف "${prop['title']}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(adminServiceProvider).deleteProperty(prop['id']);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _typeAr(String type) {
    const map = {'apartment': 'شقة', 'villa': 'فيلا', 'duplex': 'دوبلكس', 'penthouse': 'بنتهاوس', 'studio': 'استوديو', 'shop': 'محل', 'office': 'مكتب', 'clinic': 'عيادة', 'land': 'أرض', 'warehouse': 'مخزن', 'factory': 'مصنع', 'farm': 'مزرعة', 'commercial': 'تجاري', 'administrative': 'إداري'};
    return map[type] ?? type;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final n = (price as num).toDouble();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }
}
