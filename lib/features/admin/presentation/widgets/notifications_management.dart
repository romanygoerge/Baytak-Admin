import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_data_table.dart';

/// Notifications management - send notifications to users
class NotificationsManagement extends ConsumerStatefulWidget {
  const NotificationsManagement({super.key});

  @override
  ConsumerState<NotificationsManagement> createState() => _NotificationsManagementState();
}

class _NotificationsManagementState extends ConsumerState<NotificationsManagement> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _sendToAll = true;
  String? _selectedUserId;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final usersAsync = ref.watch(usersStreamProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إرسال الإشعارات', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('إرسال إشعارات للمستخدمين وعرض السجل', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),

          // Send notification form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSectionHeader(title: 'إشعار جديد', accentColor: Color(0xFF0EA5E9)),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الإشعار',
                    hintText: 'مثال: عرض خاص لعقارات مدينة السادات',
                    filled: true,
                    fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bodyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'نص الإشعار',
                    hintText: 'اكتب رسالة الإشعار هنا...',
                    filled: true,
                    fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _sendToAll,
                      onChanged: (v) => setState(() {
                        _sendToAll = v ?? true;
                        if (_sendToAll) _selectedUserId = null;
                      }),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    const Text('إرسال لجميع المستخدمين', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                if (!_sendToAll) ...[
                  const SizedBox(height: 12),
                  usersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('خطأ في تحميل المستخدمين: $e', style: const TextStyle(color: AppColors.error, fontSize: 12)),
                    data: (users) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedUserId,
                        decoration: InputDecoration(
                          labelText: 'اختر المستخدم المستهدف',
                          filled: true,
                          fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: users.map((u) {
                          final name = u['name'] ?? 'بدون اسم';
                          final emailOrPhone = u['phone'] ?? u['email'] ?? '';
                          return DropdownMenuItem<String>(
                            value: u['id']?.toString(),
                            child: Text('$name ($emailOrPhone)', style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedUserId = val),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendNotification,
                    icon: _isSending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isSending ? 'جاري الإرسال...' : 'إرسال الإشعار'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Notifications history
          notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (notifications) {
              final sorted = [...notifications]..sort((a, b) {
                  final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
                  final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
                  return dateB.compareTo(dateA);
                });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSectionHeader(title: 'سجل الإشعارات (${sorted.length})', accentColor: const Color(0xFF0EA5E9)),
                  const SizedBox(height: 16),
                  AdminDataTable(
                    isDark: isDark,
                    emptyMessage: 'لم يتم إرسال إشعارات بعد',
                    columns: const [
                      DataColumn(label: Text('العنوان')),
                      DataColumn(label: Text('النص')),
                      DataColumn(label: Text('الهدف')),
                      DataColumn(label: Text('التاريخ')),
                    ],
                    rows: sorted.map((n) {
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 140, child: Text(n['title'] ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)))),
                        DataCell(SizedBox(width: 200, child: Text(n['body'] ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))),
                        DataCell(AdminStatusChip(
                          status: n['target_all'] == true ? 'all' : 'single',
                          customMap: const {
                            'all': (Color(0xFF0EA5E9), 'الجميع'),
                            'single': (AppColors.warning, 'مستخدم محدد'),
                          },
                        )),
                        DataCell(Text(_formatDate(n['created_at']), style: const TextStyle(fontSize: 12))),
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

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء عنوان ونص الإشعار'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (!_sendToAll && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد المستخدم المستهدف'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final sentBy = Supabase.instance.client.auth.currentUser?.id ?? '';
      await ref.read(adminServiceProvider).sendNotification(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            targetUserId: _selectedUserId,
            targetAll: _sendToAll,
            sentBy: sentBy,
          );
      _titleController.clear();
      _bodyController.clear();
      setState(() => _selectedUserId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الإشعار بنجاح ✅'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    final date = DateTime.tryParse(d.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
