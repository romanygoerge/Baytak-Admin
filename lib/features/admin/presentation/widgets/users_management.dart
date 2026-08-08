import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Users management screen with search, filter, role change, block/unblock
class UsersManagement extends ConsumerStatefulWidget {
  const UsersManagement({super.key});

  @override
  ConsumerState<UsersManagement> createState() => _UsersManagementState();
}

class _UsersManagementState extends ConsumerState<UsersManagement> {
  String _search = '';
  String _roleFilter = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(usersStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إدارة المستخدمين', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('عرض وإدارة حسابات المستخدمين والصلاحيات', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
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
                    hintText: 'بحث بالاسم أو البريد أو الهاتف...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintStyle: const TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              _buildFilterChip('الكل', '', isDark),
              _buildFilterChip('مستخدم', 'user', isDark),
              _buildFilterChip('مدير', 'admin', isDark),
              _buildFilterChip('صاحب مكتب', 'officeOwner', isDark),
              _buildFilterChip('مشرف', 'moderator', isDark),
            ],
          ),
          const SizedBox(height: 24),

          usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (users) {
              var filtered = users;
              if (_roleFilter.isNotEmpty) {
                filtered = filtered.where((u) => u['role'] == _roleFilter).toList();
              }
              if (_search.isNotEmpty) {
                final s = _search.toLowerCase();
                filtered = filtered.where((u) {
                  return (u['name'] ?? '').toString().toLowerCase().contains(s) ||
                      (u['email'] ?? '').toString().toLowerCase().contains(s) ||
                      (u['phone'] ?? '').toString().contains(s);
                }).toList();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSectionHeader(title: 'المستخدمون (${filtered.length})', accentColor: const Color(0xFF3B82F6)),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لا يوجد مستخدمون',
                    columns: const [
                      DataColumn(label: Text('الاسم')),
                      DataColumn(label: Text('البريد/الهاتف')),
                      DataColumn(label: Text('الصلاحية')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('تاريخ التسجيل')),
                      DataColumn(label: Text('الإجراءات')),
                    ],
                    rows: filtered.map((u) {
                      final blocked = u['blocked'] == true;
                      return DataRow(cells: [
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              backgroundImage: u['photo_url'] != null ? NetworkImage(u['photo_url']) : null,
                              child: u['photo_url'] == null ? Text((u['name'] ?? '?')[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary)) : null,
                            ),
                            const SizedBox(width: 10),
                            SizedBox(width: 120, child: Text(u['name'] ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
                          ],
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (u['email'] != null) Text(u['email'], style: const TextStyle(fontSize: 11)),
                            if (u['phone'] != null && u['phone'].toString().isNotEmpty) Text(u['phone'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        )),
                        DataCell(AdminStatusChip(
                          status: u['role'] ?? 'user',
                          customMap: const {
                            'user': (AppColors.info, 'مستخدم'),
                            'admin': (AppColors.error, 'مدير'),
                            'superAdmin': (Color(0xFF8B5CF6), 'مدير عام'),
                            'officeOwner': (AppColors.warning, 'صاحب مكتب'),
                            'officeEmployee': (Color(0xFFEC4899), 'موظف مكتب'),
                            'moderator': (AppColors.success, 'مشرف'),
                            'support': (Color(0xFF0EA5E9), 'دعم فني'),
                            'marketing': (Color(0xFFF59E0B), 'تسويق'),
                            'contentManager': (Color(0xFF6366F1), 'مدير محتوى'),
                          },
                        )),
                        DataCell(AdminStatusChip(
                          status: blocked ? 'blocked' : 'active',
                          customMap: const {
                            'active': (AppColors.success, 'نشط'),
                            'blocked': (AppColors.error, 'محظور'),
                          },
                        )),
                        DataCell(Text(_formatDate(u['created_at']), style: const TextStyle(fontSize: 12))),
                        DataCell(_buildActions(u, blocked)),
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

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _roleFilter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 12, color: isSelected ? Colors.white : null)),
      selected: isSelected,
      onSelected: (_) => setState(() => _roleFilter = value),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      backgroundColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
    );
  }

  Widget _buildActions(Map<String, dynamic> user, bool blocked) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Role change
        PopupMenuButton<String>(
          icon: const Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.info),
          tooltip: 'تغيير الصلاحية',
          onSelected: (role) async {
            await ref.read(adminServiceProvider).updateUserRole(user['id'], role);
          },
          itemBuilder: (_) => ['user', 'admin', 'officeOwner', 'moderator', 'support'].map((r) {
            return PopupMenuItem(value: r, child: Text(_roleAr(r), style: const TextStyle(fontSize: 13)));
          }).toList(),
        ),
        // Block/unblock
        IconButton(
          icon: Icon(blocked ? Icons.lock_open_rounded : Icons.block_rounded, size: 18, color: blocked ? AppColors.success : AppColors.warning),
          tooltip: blocked ? 'إلغاء الحظر' : 'حظر',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            await ref.read(adminServiceProvider).toggleUserBlock(user['id'], !blocked);
          },
        ),
        const SizedBox(width: 4),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
          tooltip: 'حذف',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _confirmDelete(user),
        ),
      ],
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الحذف', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('هل أنت متأكد من حذف المستخدم "${user['name']}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(adminServiceProvider).deleteUser(user['id']);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _roleAr(String role) {
    const map = {'user': 'مستخدم', 'admin': 'مدير', 'superAdmin': 'مدير عام', 'officeOwner': 'صاحب مكتب', 'moderator': 'مشرف', 'support': 'دعم فني', 'marketing': 'تسويق'};
    return map[role] ?? role;
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    final date = DateTime.tryParse(d.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
