import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  // ─── Modal for Full Property Preview (App Layout Style) ───
  void _showPropertyPreviewModal(Map<String, dynamic> prop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = List<String>.from(prop['images'] ?? []);
    final title = prop['title'] ?? 'بدون عنوان';
    final price = prop['price'] ?? 0;
    final area = prop['area'] ?? 0;
    final desc = prop['description'] ?? 'لا يوجد وصف تفصيلي لهذا العقار';
    final type = prop['type'] ?? 'apartment';
    final purpose = prop['purpose'] ?? 'sale';
    final status = prop['status'] ?? 'pending';
    final isFeatured = prop['featured'] == true;
    final rooms = prop['rooms'] ?? prop['bedrooms'] ?? 0;
    final bathrooms = prop['bathrooms'] ?? 0;
    final floor = prop['floor'] ?? 0;
    final finishing = prop['finishing'] ?? '';
    final facing = prop['facing'] ?? '';
    final views = prop['views'] ?? prop['views_count'] ?? 0;
    final rejectionReason = prop['rejection_reason'] ?? '';
    final ownerId = prop['owner_id'] ?? prop['ownerId'] ?? prop['user_id'] ?? '';
    final phone = prop['contact_phone'] ?? prop['phone'] ?? prop['owner_phone'] ?? '';
    final whatsapp = prop['whatsapp'] ?? prop['whatsapp_number'] ?? phone;

    String locationText = 'مدينة السادات';
    if (prop['location'] is Map) {
      final loc = prop['location'] as Map;
      final areaName = loc['area'] ?? loc['city'] ?? loc['district'] ?? '';
      final address = loc['address'] ?? loc['street'] ?? '';
      if (areaName.toString().isNotEmpty) {
        locationText = address.toString().isNotEmpty ? '$areaName - $address' : areaName.toString();
      }
    } else if (prop['location'] is String && prop['location'].toString().isNotEmpty) {
      locationText = prop['location'].toString();
    }

    int activeImageIdx = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 960,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ─── Header Bar ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.remove_red_eye_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'معاينة العقار بالكامل',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                                const SizedBox(width: 10),
                                AdminStatusChip(status: status),
                                if (isFeatured) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.featured.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.featured.withValues(alpha: 0.4)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.star_rounded, size: 12, color: AppColors.featured),
                                        SizedBox(width: 3),
                                        Text('مميز', style: TextStyle(color: AppColors.featured, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text('معاينة العرض التفصيلي كأنه يظهر للعميل داخل التطبيق', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const Spacer(),

                        if (status != 'active') ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(dialogCtx);
                              await _approveProperty(prop);
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text('موافقة ونشر', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (status != 'rejected') ...[
                          OutlinedButton.icon(
                            onPressed: () async {
                              Navigator.pop(dialogCtx);
                              await _rejectPropertyModal(prop);
                            },
                            icon: const Icon(Icons.cancel_rounded, size: 16),
                            label: const Text('رفض الإعلان', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                  ),

                  // ─── Main Preview Content Body ──────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 720;

                          final gallerySection = _buildPreviewGallery(images, activeImageIdx, (idx) {
                            setModalState(() => activeImageIdx = idx);
                          }, isDark);

                          final detailsSection = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Price Header
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.3)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                                            const SizedBox(width: 4),
                                            Text(locationText, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.remove_red_eye_rounded, size: 14, color: AppColors.textHint),
                                            const SizedBox(width: 4),
                                            Text('$views مشاهدة', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${_formatFullPrice(price)} ج.م',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                                        ),
                                        Text(
                                          purpose == 'rent' ? 'للإيجار' : 'للبيع',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: purpose == 'rent' ? AppColors.forRent : AppColors.forSale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Key Specifications Grid
                              const Text('المواصفات الرئيسية:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _specBadge(Icons.square_foot_rounded, 'المساحة', '$area م²', isDark),
                                  if (rooms > 0) _specBadge(Icons.bed_rounded, 'الغرف', '$rooms غرف', isDark),
                                  if (bathrooms > 0) _specBadge(Icons.bathtub_rounded, 'الحمامات', '$bathrooms حمام', isDark),
                                  if (floor > 0) _specBadge(Icons.apartment_rounded, 'الدور', 'الدور $floor', isDark),
                                  _specBadge(Icons.home_work_rounded, 'النوع', _typeAr(type), isDark),
                                  if (finishing.toString().isNotEmpty) _specBadge(Icons.brush_rounded, 'التشطيب', _finishingAr(finishing.toString()), isDark),
                                  if (facing.toString().isNotEmpty) _specBadge(Icons.explore_rounded, 'الواجهة', _facingAr(facing.toString()), isDark),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Description Section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.description_rounded, size: 18, color: AppColors.primary),
                                        SizedBox(width: 6),
                                        Text('الوصف التفصيلي للإعلان:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      desc,
                                      style: const TextStyle(fontSize: 13, height: 1.6),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Features List
                              _buildFeaturesSection(prop['features'], isDark),
                              const SizedBox(height: 20),

                              // Owner / Publisher Info Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.person_rounded, color: AppColors.primary, size: 18),
                                        SizedBox(width: 6),
                                        Text('معلومات المعلن والتواصل:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        if (ownerId.toString().isNotEmpty)
                                          Text('معرف المعلن: ${ownerId.toString().substring(0, ownerId.toString().length > 8 ? 8 : ownerId.toString().length)}...', style: const TextStyle(fontSize: 12)),
                                        if (phone.toString().isNotEmpty)
                                          Text('📞 الهاتف: $phone', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        if (whatsapp.toString().isNotEmpty)
                                          Text('💬 واتساب: $whatsapp', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                      ],
                                    ),
                                    if (rejectionReason.toString().isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                        ),
                                        child: Text('سبب الرفض السابق: $rejectionReason', style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: gallerySection),
                                const SizedBox(width: 24),
                                Expanded(flex: 6, child: detailsSection),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                gallerySection,
                                const SizedBox(height: 20),
                                detailsSection,
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewGallery(List<String> images, int activeIdx, Function(int) onSelect, bool isDark) {
    if (images.isEmpty) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.textHint),
              SizedBox(height: 8),
              Text('لا توجد صور مرفقة لهذا العقار', style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    final currentUrl = activeIdx < images.length ? images[activeIdx] : images.first;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: currentUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activeIdx + 1} / ${images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (images.length > 1)
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (ctx, i) {
                final isSelected = i == activeIdx;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _specBadge(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(dynamic featuresData, bool isDark) {
    List<String> featureItems = [];
    if (featuresData is Map) {
      featuresData.forEach((k, v) {
        if (v == true) featureItems.add(_featureKeyToAr(k.toString()));
      });
    } else if (featuresData is List) {
      featureItems = featuresData.map((e) => _featureKeyToAr(e.toString())).toList();
    }

    if (featureItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المميزات ووسائل الراحة:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: featureItems.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(item, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _featureKeyToAr(String key) {
    const map = {
      'elevator': 'مصعد (أسانسير)',
      'parking': 'موقف سيارات',
      'security': 'حراسة وأمن',
      'gas': 'غاز طبيعي',
      'water_meter': 'عداد مياه',
      'electric_meter': 'عداد كهرباء',
      'garden': 'حديقة خاصة',
      'pool': 'حمام سباحة',
      'balcony': 'بلكونة / تراس',
      'air_conditioner': 'تكييف',
      'furnished': 'مفروش بالكامل',
    };
    return map[key] ?? key;
  }

  String _finishingAr(String f) {
    const map = {
      'super_lux': 'سوبر لوكس',
      'ultra_lux': 'ألترا لوكس',
      'lux': 'لوكس',
      'semi_finished': 'نصف تشطيب',
      'unfurnished': 'بدون تشطيب',
      'none': 'بدون تشطيب',
    };
    return map[f] ?? f;
  }

  String _facingAr(String f) {
    const map = {
      'north': 'بحري',
      'south': 'قبلي',
      'east': 'شرقي',
      'west': 'غربي',
      'northeast': 'بحري شرقي',
      'northwest': 'بحري غربي',
    };
    return map[f] ?? f;
  }

  String _formatFullPrice(dynamic p) {
    if (p == null) return '0';
    final num = double.tryParse(p.toString()) ?? 0;
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(2)} مليون';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)} ألف';
    return num.toStringAsFixed(0);
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
