import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable styled DataTable wrapper for admin screens
class AdminDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isDark;
  final String? emptyMessage;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.isDark,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: _boxDecoration,
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.textHint.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              emptyMessage ?? 'لا توجد بيانات',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: _boxDecoration,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          horizontalMargin: 20,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 56,
          columnSpacing: 24,
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white70 : AppColors.textPrimary,
            fontSize: 13,
          ),
          dataTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

/// Status chip used across admin tables
class AdminStatusChip extends StatelessWidget {
  final String status;
  final Map<String, (Color, String)>? customMap;

  const AdminStatusChip({super.key, required this.status, this.customMap});

  @override
  Widget build(BuildContext context) {
    final mapping = customMap ??
        {
          'active': (AppColors.success, 'نشط'),
          'pending': (AppColors.warning, 'قيد المراجعة'),
          'rejected': (AppColors.error, 'مرفوض'),
          'sold': (const Color(0xFF6366F1), 'تم البيع'),
          'rented': (const Color(0xFF8B5CF6), 'تم التأجير'),
          'draft': (AppColors.textHint, 'مسودة'),
          'expired': (AppColors.textHint, 'منتهي'),
          'resolved': (AppColors.success, 'تم المعالجة'),
          'dismissed': (AppColors.textHint, 'مرفوض'),
          'cancelled': (AppColors.error, 'ملغي'),
        };
    final (color, label) = mapping[status] ?? (AppColors.textHint, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Section header used across admin pages
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget? trailing;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.accentColor = AppColors.primary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}
