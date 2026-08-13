import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/banner_model.dart';
import '../providers/admin_providers.dart';

/// Banners management widget - Full CRUD control over homepage carousel banners
class BannersManagement extends ConsumerStatefulWidget {
  const BannersManagement({super.key});

  @override
  ConsumerState<BannersManagement> createState() => _BannersManagementState();
}

class _BannersManagementState extends ConsumerState<BannersManagement> {
  // Predefined gradients SYNCED with app's AppColors.bannerGradients
  static const List<LinearGradient> bannerGradients = [
    // 0: Midnight Navy
    LinearGradient(
      colors: [Color(0xFF132238), Color(0xFF1E3A5F), Color(0xFF2A4D7C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 1: Royal Gold
    LinearGradient(
      colors: [Color(0xFFC5A059), Color(0xFFE5C158), Color(0xFFF5E096)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 2: Navy + Gold Blend
    LinearGradient(
      colors: [Color(0xFF0B1524), Color(0xFF132238), Color(0xFFC5A059)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 3: Emerald Green
    LinearGradient(
      colors: [Color(0xFF059669), Color(0xFF0D9488), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 4: Royal Blue
    LinearGradient(
      colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static const Map<String, String> targetTypeLabels = {
    'category': 'قسم / نوع العقار',
    'purpose': 'الغرض (بيع/إيجار)',
    'featured': 'عقارات مميزة',
    'property': 'عقار محدد',
    'route': 'رابط / صفحة داخلية',
  };

  static const Map<String, String> categoryNames = {
    'apartment': 'شقق',
    'villa': 'فيلات',
    'land': 'أراضي',
    'commercial': 'محلات ومكاتب تجارية',
    'building': 'عماير ومباني',
    'chalet': 'شاليهات',
    'duplex': 'دوبلكس',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannersAsync = ref.watch(bannersStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header & Add Action ─────────────────────────────────
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.view_carousel_rounded, color: Color(0xFF8B5CF6), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'إدارة البانرات المتحركة',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'التحكم الكامل في إعلانات الصفحة الرئيسية للتطبيق وتوجيه العملاء لأي قسم',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showBannerFormDialog(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('إضافة بانر جديد', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Data View ───────────────────────────────────────────
          bannersAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: SelectableText('خطأ أثناء تحميل البيانات: $e', style: const TextStyle(color: AppColors.error)),
              ),
            ),
            data: (rawList) {
              final banners = rawList.map((e) => BannerModel.fromJson(e)).toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

              if (banners.isEmpty) {
                return _buildEmptyState(context, isDark);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat Chips
                  Row(
                    children: [
                      _buildMiniStatChip('إجمالي البانرات', '${banners.length}', Colors.blue),
                      const SizedBox(width: 12),
                      _buildMiniStatChip('المفعلة', '${banners.where((b) => b.isActive).length}', AppColors.success),
                      const SizedBox(width: 12),
                      _buildMiniStatChip('الموقوفة', '${banners.where((b) => !b.isActive).length}', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Drag & Drop reorder tip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.drag_indicator_rounded, size: 18, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'اسحب وأفلت البانرات لإعادة ترتيبها — التغييرات تتزامن فوراً مع التطبيق',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Banner Reorderable List
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        elevation: 8,
                        borderRadius: BorderRadius.circular(16),
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        child: child,
                      );
                    },
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final movedBanner = banners.removeAt(oldIndex);
                      banners.insert(newIndex, movedBanner);

                      // Update sort_order for all banners
                      final service = ref.read(adminServiceProvider);
                      for (int i = 0; i < banners.length; i++) {
                        final b = banners[i];
                        if (b.sortOrder != i + 1) {
                          await service.updateBanner(b.id, {
                            'sort_order': i + 1,
                            'updated_at': DateTime.now().toIso8601String(),
                          });
                        }
                      }
                    },
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return ReorderableDragStartListener(
                        key: ValueKey(banner.id),
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildBannerCard(banner, isDark, orderIndex: index),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.view_carousel_outlined, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('لا توجد بانرات مسجلة حتى الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('قم بإضافة أول بانر إعلاني ليظهر في التطبيق', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showBannerFormDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة بانر الآن'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(BannerModel banner, bool isDark, {int orderIndex = 0}) {
    final gradient = bannerGradients[banner.gradientIndex % bannerGradients.length];
    final hasImage = banner.imageUrl != null && banner.imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: banner.isActive ? AppColors.primary.withValues(alpha: 0.3) : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: banner.isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Container(
            width: 36,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${orderIndex + 1}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(Icons.drag_indicator_rounded, size: 20, color: isDark ? Colors.white30 : AppColors.textHint),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Banner Visual Preview
          Container(
            width: 200,
            height: 140,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: !hasImage ? gradient : null,
              color: hasImage ? Colors.black87 : null,
              borderRadius: BorderRadius.circular(12),
              image: hasImage
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(banner.imageUrl!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // Decorative shape
                if (!hasImage)
                  Positioned(
                    top: -15,
                    right: -15,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          if (banner.emoji != null && banner.emoji!.isNotEmpty)
                            Text(banner.emoji!, style: const TextStyle(fontSize: 16)),
                          if (banner.emoji != null && banner.emoji!.isNotEmpty) const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              banner.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          banner.ctaText,
                          style: TextStyle(color: gradient.colors.first, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Image badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: hasImage ? AppColors.success.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasImage ? Icons.image_rounded : Icons.palette_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          hasImage ? 'صورة' : 'تدرج',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details & Actions
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    banner.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),

                  // Target Binding Info
                  Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getFormattedTargetDescription(banner),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Controls: Active Switch & Action buttons
                  Row(
                    children: [
                      // Active Status Switch
                      Transform.scale(
                        scale: 0.75,
                        child: Switch(
                          value: banner.isActive,
                          activeTrackColor: AppColors.success,
                          onChanged: (val) async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref.read(adminServiceProvider).toggleBannerActive(banner.id, val);
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(val ? 'تم تفعيل البانر' : 'تم إيقاف البانر'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: val ? AppColors.success : AppColors.warning,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(content: Text('خطأ أثناء التغيير: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          },
                        ),
                      ),
                      Text(
                        banner.isActive ? 'مفعل' : 'موقوف',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: banner.isActive ? AppColors.success : AppColors.textHint,
                        ),
                      ),
                      const Spacer(),
                      // Remove image (if exists)
                      if (hasImage)
                        IconButton(
                          icon: const Icon(Icons.hide_image_outlined, size: 17, color: AppColors.warning),
                          tooltip: 'حذف الصورة (إرجاع التدرج اللوني)',
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref.read(adminServiceProvider).updateBanner(banner.id, {
                                'image_url': null,
                                'updated_at': DateTime.now().toIso8601String(),
                              });
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(content: Text('تم حذف صورة البانر وإرجاع التدرج اللوني'), backgroundColor: AppColors.info),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(content: Text('خطأ أثناء حذف الصورة: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          },
                        ),
                      // Edit
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.info),
                        tooltip: 'تعديل',
                        onPressed: () => _showBannerFormDialog(context, banner: banner),
                      ),
                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 17, color: AppColors.error),
                        tooltip: 'حذف',
                        onPressed: () => _confirmDelete(banner),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedTargetDescription(BannerModel banner) {
    switch (banner.targetType) {
      case 'category':
        final cat = categoryNames[banner.targetValue] ?? banner.targetValue ?? 'الكل';
        return 'قسم: $cat';
      case 'purpose':
        final p = banner.targetValue == 'sale'
            ? 'للبيع'
            : banner.targetValue == 'rent'
                ? 'للإيجار'
                : 'الكل';
        return 'غرض: $p';
      case 'featured':
        return 'عقارات مميزة';
      case 'property':
        return 'عقار محدد (${banner.targetValue ?? ''})';
      case 'route':
        return 'مسار: ${banner.targetValue ?? ''}';
      default:
        return banner.targetType;
    }
  }

  // ─── Add / Edit Banner Dialog ────────────────────────────────────

  void _showBannerFormDialog(BuildContext context, {BannerModel? banner}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = banner != null;
    final titleC = TextEditingController(text: banner?.title ?? '');
    final subtitleC = TextEditingController(text: banner?.subtitle ?? '');
    final emojiC = TextEditingController(text: banner?.emoji ?? '🏠');
    final ctaC = TextEditingController(text: banner?.ctaText ?? 'تصفح الآن');
    final sortC = TextEditingController(text: '${banner?.sortOrder ?? 0}');
    final imageUrlC = TextEditingController(text: banner?.imageUrl ?? '');
    final targetValueC = TextEditingController(text: banner?.targetValue ?? 'apartment');

    String selectedTargetType = banner?.targetType ?? 'category';
    String selectedCategory = (selectedTargetType == 'category' && banner?.targetValue != null) ? banner!.targetValue! : 'apartment';
    String selectedPurpose = (selectedTargetType == 'purpose' && banner?.targetValue != null) ? banner!.targetValue! : 'sale';
    int selectedGradient = banner?.gradientIndex ?? 0;
    bool isActive = banner?.isActive ?? true;

    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_rounded : Icons.add_photo_alternate_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'تعديل البانر' : 'إضافة بانر جديد',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 540,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Banner Live Preview ──────────────────────
                      const Text('معاينة حية للبانر:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        height: 140,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: selectedImageBytes == null && imageUrlC.text.isEmpty
                              ? bannerGradients[selectedGradient % bannerGradients.length]
                              : null,
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          image: selectedImageBytes != null
                              ? DecorationImage(image: MemoryImage(selectedImageBytes!), fit: BoxFit.cover)
                              : imageUrlC.text.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(imageUrlC.text), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                if (emojiC.text.isNotEmpty) Text(emojiC.text, style: const TextStyle(fontSize: 18)),
                                if (emojiC.text.isNotEmpty) const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    titleC.text.isEmpty ? 'عنوان البانر الإعلاني' : titleC.text,
                                    maxLines: 1,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitleC.text.isEmpty ? 'وصف تسويقي مبسط للبانر يظهر للعميل' : subtitleC.text,
                              maxLines: 2,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                ctaC.text.isEmpty ? 'تصفح الآن' : ctaC.text,
                                style: TextStyle(
                                  color: bannerGradients[selectedGradient % bannerGradients.length].colors.first,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Fields ──────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: titleC,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: InputDecoration(
                                labelText: 'عنوان البانر الرئيسي *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: emojiC,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: InputDecoration(
                                labelText: 'إيموجي',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: subtitleC,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: 'الوصف الفرعي *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctaC,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: InputDecoration(
                                labelText: 'نص زر الإجراء (CTA)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: sortC,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'ترتيب العرض (0, 1, 2)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ─── Gradient Selection ──────────────────────
                      const Text('اختر النمط/اللون الخلفي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(bannerGradients.length, (idx) {
                          final isSel = selectedGradient == idx;
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedGradient = idx),
                            child: Container(
                              margin: const EdgeInsets.only(left: 10),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: bannerGradients[idx],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSel
                                    ? [BoxShadow(color: bannerGradients[idx].colors.first.withValues(alpha: 0.6), blurRadius: 8)]
                                    : null,
                              ),
                              child: isSel ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // ─── Image Upload / URL ───────────────────────
                      const Text('صورة خلفية مخصصة (اختياري):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                              if (file != null) {
                                final bytes = await file.readAsBytes();
                                setDialogState(() {
                                  selectedImageBytes = bytes;
                                  selectedImageName = file.name;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file_rounded, size: 18),
                            label: Text(selectedImageBytes != null ? 'تغيير الصورة' : 'رفع صورة من الجهاز'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                              foregroundColor: AppColors.secondary,
                              elevation: 0,
                            ),
                          ),
                          if (selectedImageBytes != null) ...[
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => setDialogState(() {
                                selectedImageBytes = null;
                                selectedImageName = null;
                              }),
                              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                              label: const Text('إلغاء', style: TextStyle(color: AppColors.error, fontSize: 12)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: imageUrlC,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          labelText: 'أو أدخل رابط صورة مباشر (URL)',
                          hintText: 'https://images.unsplash.com/...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Target Link / Section Binding (ربط البانر) ─
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'توجيه الضغط (ربط البانر بقسم):',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Target Type Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: selectedTargetType,
                              decoration: InputDecoration(
                                labelText: 'نوع الوجهة عند الضغط على البانر',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                              ),
                              items: targetTypeLabels.entries.map((e) {
                                return DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedTargetType = val;
                                    if (val == 'category') {
                                      targetValueC.text = selectedCategory;
                                    } else if (val == 'purpose') {
                                      targetValueC.text = selectedPurpose;
                                    } else if (val == 'featured') {
                                      targetValueC.text = 'true';
                                    } else {
                                      targetValueC.clear();
                                    }
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 12),

                            // Target Value Field depending on type
                            if (selectedTargetType == 'category') ...[
                              DropdownButtonFormField<String>(
                                initialValue: categoryNames.containsKey(selectedCategory) ? selectedCategory : 'apartment',
                                decoration: InputDecoration(
                                  labelText: 'اختر القسم التفاعلي',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                ),
                                items: categoryNames.entries.map((e) {
                                  return DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedCategory = val;
                                      targetValueC.text = val;
                                    });
                                  }
                                },
                              ),
                            ] else if (selectedTargetType == 'purpose') ...[
                              DropdownButtonFormField<String>(
                                initialValue: selectedPurpose,
                                decoration: InputDecoration(
                                  labelText: 'اختر الغرض',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'sale', child: Text('عقارات للبيع')),
                                  DropdownMenuItem(value: 'rent', child: Text('عقارات للإيجار')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedPurpose = val;
                                      targetValueC.text = val;
                                    });
                                  }
                                },
                              ),
                            ] else if (selectedTargetType == 'property') ...[
                              TextField(
                                controller: targetValueC,
                                decoration: InputDecoration(
                                  labelText: 'معرف العقار (Property ID)',
                                  hintText: 'أدخل معرف العقار بالتحديد',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                ),
                              ),
                            ] else if (selectedTargetType == 'route') ...[
                              TextField(
                                controller: targetValueC,
                                decoration: InputDecoration(
                                  labelText: 'مسار الصفحة في التطبيق (Route)',
                                  hintText: '/offices أو /search أو رابط خارجي',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Active Switch ───────────────────────────
                      Row(
                        children: [
                          Switch(
                            value: isActive,
                            activeTrackColor: AppColors.success,
                            onChanged: (val) => setDialogState(() => isActive = val),
                          ),
                          Text(
                            isActive ? 'البانر مفعل ونشط للظهور فورا' : 'البانر موقوف (مسودة)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (titleC.text.trim().isEmpty || subtitleC.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('الرجاء كتابة عنوان ووصف البانر')),
                            );
                            return;
                          }

                          setDialogState(() => isUploading = true);

                          try {
                            String? finalImageUrl = imageUrlC.text.trim().isNotEmpty ? imageUrlC.text.trim() : banner?.imageUrl;

                            if (selectedImageBytes != null) {
                              final uploadedUrl = await ref.read(adminServiceProvider).uploadBannerImage(
                                    selectedImageBytes!,
                                    selectedImageName ?? 'banner.png',
                                  );
                              if (uploadedUrl != null) {
                                finalImageUrl = uploadedUrl;
                              }
                            }

                            String targetVal = targetValueC.text.trim();
                            if (selectedTargetType == 'category' && targetVal.isEmpty) {
                              targetVal = selectedCategory;
                            } else if (selectedTargetType == 'purpose' && targetVal.isEmpty) {
                              targetVal = selectedPurpose;
                            }

                            final data = {
                              'title': titleC.text.trim(),
                              'subtitle': subtitleC.text.trim(),
                              'emoji': emojiC.text.trim().isEmpty ? null : emojiC.text.trim(),
                              'cta_text': ctaC.text.trim().isEmpty ? 'تصفح الآن' : ctaC.text.trim(),
                              'gradient_index': selectedGradient,
                              'image_url': finalImageUrl,
                              'target_type': selectedTargetType,
                              'target_value': targetVal.isEmpty ? null : targetVal,
                              'sort_order': int.tryParse(sortC.text.trim()) ?? 0,
                              'is_active': isActive,
                              'updated_at': DateTime.now().toIso8601String(),
                            };

                            if (isEditing) {
                              await ref.read(adminServiceProvider).updateBanner(banner.id, data);
                            } else {
                              data['created_at'] = DateTime.now().toIso8601String();
                              await ref.read(adminServiceProvider).addBanner(data);
                            }

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing ? 'تم تعديل البانر بنجاح' : 'تم إضافة البانر بنجاح'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isUploading = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                  child: isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'حفظ التعديلات' : 'إضافة البانر', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BannerModel banner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف البانر', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت تأكد من حذف البانر "${banner.title}"؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminServiceProvider).deleteBanner(banner.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف البانر بنجاح'), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ أثناء الحذف: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
