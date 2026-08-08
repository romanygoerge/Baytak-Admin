import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Properties management screen with preview, approve, reject with reason, feature, & delete
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
        // 👁️ Preview details button
        IconButton(
          icon: const Icon(Icons.remove_red_eye_rounded, color: AppColors.primary, size: 20),
          tooltip: 'معاينة العقار',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _showPropertyPreviewModal(prop),
        ),
        const SizedBox(width: 6),
        // ✅ Approve
        if (status != 'active')
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
            tooltip: 'موافقة ونشر الإعلان',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _approveProperty(prop),
          ),
        if (status != 'active') const SizedBox(width: 6),
        // ❌ Reject with reason
        if (status != 'rejected')
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
            tooltip: 'رفض الإعلان مع السبب',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _rejectPropertyModal(prop),
          ),
        if (status != 'rejected') const SizedBox(width: 6),
        // ⭐ Toggle featured
        IconButton(
          icon: Icon(isFeatured ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.featured, size: 20),
          tooltip: isFeatured ? 'إلغاء التثبيت' : 'تثبيت',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async => await ref.read(adminServiceProvider).togglePropertyFeatured(prop['id'], !isFeatured),
        ),
        const SizedBox(width: 6),
        // 🗑️ Delete
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

  // ─── Actions: Approve Property ───
  Future<void> _approveProperty(Map<String, dynamic> prop) async {
    final propertyId = prop['id']?.toString() ?? '';
    final ownerId = prop['owner_id'] ?? prop['ownerId'] ?? prop['user_id'] ?? prop['userId'] ?? '';
    final title = prop['title'] ?? 'عقار بدون عنوان';

    await ref.read(adminServiceProvider).updatePropertyStatus(propertyId, 'active');

    if (ownerId.toString().isNotEmpty) {
      await NotificationService.sendPropertyStatusNotification(
        ownerUserId: ownerId.toString(),
        propertyTitle: title.toString(),
        isApproved: true,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت الموافقة على نشر عقار "$title" وإشعار المعلن 🎉'), backgroundColor: AppColors.success),
      );
    }
  }

  // ─── Actions: Reject Property Modal with Reason ───
  Future<void> _rejectPropertyModal(Map<String, dynamic> prop) async {
    final reasonController = TextEditingController();
    final propertyId = prop['id']?.toString() ?? '';
    final ownerId = prop['owner_id'] ?? prop['ownerId'] ?? prop['user_id'] ?? prop['userId'] ?? '';
    final title = prop['title'] ?? 'عقار بدون عنوان';

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('رفض الإعلان العقاري'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يرجى كتابة سبب رفض إعلان "$title" لإرساله للمعلن:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'مثال: الصور غير واضحة / السعر غير منطقي / البيانات مفقودة...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim()),
            child: const Text('تأكيد الرفض والإشعار'),
          ),
        ],
      ),
    );

    if (result != null) {
      final supabase = Supabase.instance.client;
      await supabase.from('properties').update({
        'status': 'rejected',
        'rejection_reason': result,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', propertyId);

      if (ownerId.toString().isNotEmpty) {
        await NotificationService.sendPropertyStatusNotification(
          ownerUserId: ownerId.toString(),
          propertyTitle: title.toString(),
          isApproved: false,
          rejectionReason: result.isNotEmpty ? result : 'عدم استيفاء البيانات الشاملة المطلوبة',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفض إعلان "$title" وإشعار المعلن بالسبب ❌'), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  // ─── Modal for Full Property Preview ───
  void _showPropertyPreviewModal(Map<String, dynamic> prop) {
    final images = List<String>.from(prop['images'] ?? []);
    final title = prop['title'] ?? 'بدون عنوان';
    final price = prop['price'] ?? 0;
    final area = prop['area'] ?? 0;
    final desc = prop['description'] ?? 'لا يوجد وصف تفصيلي';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.preview_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('معاينة العقار بالكامل', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (images.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(images[i], width: 260, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Text('لا توجد صور مرفقة للعقار')),
                      ),
                    const SizedBox(height: 20),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text('$price ج.م • $area م²', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 16),
                    const Text('الوصف التفصيلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(height: 1.5, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    const map = {'apartment': 'شقة', 'villa': 'فيلا', 'duplex': 'دوبلكس', 'penthouse': 'بنتهاوس', 'studio': 'استوديو', 'shop': 'محل', 'office': 'مكتب', 'land': 'أرض'};
    return map[type] ?? type;
  }

  String _formatPrice(dynamic p) {
    if (p == null) return '0';
    final num = double.tryParse(p.toString()) ?? 0;
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)} مليون';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)} ألف';
    return num.toStringAsFixed(0);
  }
}
