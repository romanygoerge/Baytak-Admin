import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Users management screen with search, filter, role change, block/unblock, verified badge, & direct message
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
                      final isVerified = u['verified'] == true;

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
                            Flexible(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      u['name'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  if (isVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                                  ],
                                ],
                              ),
                            ),
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
                        DataCell(_buildActions(u, blocked, isVerified)),
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

  Widget _buildActions(Map<String, dynamic> user, bool blocked, bool isVerified) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✉️ Send Direct Official Message Button
        IconButton(
          icon: const Icon(Icons.send_rounded, size: 18, color: Colors.blue),
          tooltip: 'إرسال رسالة رسمية باسم تطبيق بيتك 🔵',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _sendAdminMessageModal(user),
        ),
        const SizedBox(width: 4),
        // 🌟 Toggle Verify Badge
        IconButton(
          icon: Icon(isVerified ? Icons.verified_user_rounded : Icons.verified_user_outlined, size: 18, color: isVerified ? Colors.blue : Colors.grey),
          tooltip: isVerified ? 'إلغاء التوثيق' : 'توثيق الحساب 🌟',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            final supabase = Supabase.instance.client;
            await supabase.from('profiles').update({'verified': !isVerified}).eq('id', user['id']);
            setState(() {});
          },
        ),
        const SizedBox(width: 4),
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

  // ─── Modal for Admin Direct Message with Verified Badge ───
  Future<void> _sendAdminMessageModal(Map<String, dynamic> user) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'إرسال رسالة رسمية إلى ${user['name'] ?? "المستخدم"}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ستصل الرسالة للمستخدم باسم "تطبيق بيتك" ومرفقة بعلامة التوثيق الزرقاء 🔵 بالرسائل والإشعارات.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'موضوع الرسالة / العنوان',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'مضمون الرسالة',
                hintText: 'اكتب الرسالة المراد توجيهها للمستخدم...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('إرسال الآن 🔵'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final titleText = titleController.text.trim();
      final msgText = messageController.text.trim();
      final userId = user['id']?.toString() ?? '';

      if (msgText.isEmpty || userId.isEmpty) return;

      try {
        final supabase = Supabase.instance.client;
        const systemAdminId = '00000000-0000-0000-0000-000000000001';
        final now = DateTime.now();

        // 1. Ensure System Admin Profile exists in Supabase
        final existingAdmin = await supabase.from('profiles').select('id').eq('id', systemAdminId).maybeSingle();
        if (existingAdmin == null) {
          await supabase.from('profiles').insert({
            'id': systemAdminId,
            'name': 'تطبيق بيتك',
            'phone': '01000000000',
            'role': 'admin',
            'verified': true,
            'created_at': now.toIso8601String(),
          });
        }

        // 2. Check or Create Conversation
        String convId = 'admin_conv_$userId';
        final existingConv = await supabase.from('conversations').select('id').eq('id', convId).maybeSingle();

        final fullMsg = titleText.isNotEmpty ? '[$titleText]\n$msgText' : msgText;

        if (existingConv == null) {
          await supabase.from('conversations').insert({
            'id': convId,
            'participants': [systemAdminId, userId],
            'last_message': fullMsg,
            'last_sender_id': systemAdminId,
            'last_message_at': now.toIso8601String(),
            'created_at': now.toIso8601String(),
          });
        } else {
          await supabase.from('conversations').update({
            'last_message': fullMsg,
            'last_sender_id': systemAdminId,
            'last_message_at': now.toIso8601String(),
          }).eq('id', convId);
        }

        // 3. Insert Message
        await supabase.from('messages').insert({
          'id': 'msg_${now.millisecondsSinceEpoch}',
          'conversation_id': convId,
          'sender_id': systemAdminId,
          'content': fullMsg,
          'status': 'sent',
          'type': 'text',
          'created_at': now.toIso8601String(),
        });

        // 4. Insert in-app Notification
        await supabase.from('notifications').insert({
          'user_id': userId,
          'title': 'تطبيق بيتك 🔵: ${titleText.isNotEmpty ? titleText : "رسالة رسمية"}',
          'body': msgText,
          'type': 'admin_direct_message',
          'read': false,
          'created_at': now.toIso8601String(),
        });

        // 5. Trigger Push Notification
        await NotificationService.sendAdminDirectMessageNotification(
          recipientUserId: userId,
          title: titleText.isNotEmpty ? titleText : 'رسالة رسمية من إدارة التطبيق',
          messageText: msgText,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إرسال الرسالة الرسمية بنجاح إلى "${user['name']}" وإشعاره بها 🔵🎉'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ أثناء إرسال الرسالة: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
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
