import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class SupportConversations extends ConsumerStatefulWidget {
  const SupportConversations({super.key});

  @override
  ConsumerState<SupportConversations> createState() => _SupportConversationsState();
}

class _SupportConversationsState extends ConsumerState<SupportConversations> {
  final TextEditingController _chatInputCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();

  String? _selectedConvId;
  String? _selectedUserId;
  String? _selectedUserName;

  @override
  void dispose() {
    _chatInputCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supabase = ref.watch(adminServiceProvider).supabase;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'محادثات المستخدمين والدعم الفني 💬',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'متابعة رسائل واستفسارات المستخدمين والرد المباشر بصفة تطبيق بيتك 🔵',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 800;

                final listPane = Container(
                  width: isNarrow ? double.infinity : 340,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'بحث في المحادثات...',
                            hintStyle: const TextStyle(fontSize: 12),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18),
                            filled: true,
                            fillColor: isDark ? AppColors.inputFillDark : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const Divider(height: 1),

                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: supabase.from('conversations').stream(primaryKey: ['id']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final convs = snapshot.data ?? [];
                            if (convs.isEmpty) {
                              return const Center(
                                child: Text('لا توجد محادثات نشطة حالياً', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              );
                            }

                            return ListView.separated(
                              itemCount: convs.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final conv = convs[index];
                                final convId = conv['id']?.toString() ?? '';
                                final isSelected = _selectedConvId == convId;
                                final lastMsg = conv['last_message']?.toString() ?? 'رسالة جديدة';

                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF0F172A),
                                    child: Icon(Icons.person, color: Colors.white, size: 18),
                                  ),
                                  title: Text('مستخدم #${convId.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                  subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
                                  onTap: () {
                                    setState(() {
                                      _selectedConvId = convId;
                                      _selectedUserId = conv['user_id']?.toString();
                                      _selectedUserName = 'مستخدم #${convId.substring(0, 6)}';
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );

                final chatPane = Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: _selectedConvId == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 54, color: AppColors.primary),
                              SizedBox(height: 14),
                              Text('اختر محادثة من القائمة لعرض الرسائل والرد على العميل', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1B2A40) : const Color(0xFFF8FAFC),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                              ),
                              child: Row(
                                children: [
                                  if (isNarrow) ...[
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_rounded),
                                      onPressed: () => setState(() => _selectedConvId = null),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary,
                                    child: Icon(Icons.support_agent_rounded, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(_selectedUserName ?? 'محادثة مستخدم', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                ],
                              ),
                            ),

                            Expanded(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: supabase
                                    .from('messages')
                                    .stream(primaryKey: ['id'])
                                    .eq('conversation_id', _selectedConvId!)
                                    .order('created_at', ascending: true),
                                builder: (context, msgSnap) {
                                  final msgs = msgSnap.data ?? [];
                                  if (msgs.isEmpty) {
                                    return const Center(child: Text('لا توجد رسائل في هذه المحادثة بعد', style: TextStyle(color: Colors.grey)));
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: msgs.length,
                                    itemBuilder: (context, i) {
                                      final m = msgs[i];
                                      final isMe = m['sender_id'] == '00000000-0000-0000-0000-000000000001';
                                      final content = m['content']?.toString() ?? '';

                                      return Align(
                                        alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isMe ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            content,
                                            style: TextStyle(
                                              color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            // Reply Input
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _chatInputCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'اكتب رداً رسمياً للمستخدم باسم تطبيق بيتك 🔵...',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        filled: true,
                                        fillColor: isDark ? AppColors.inputFillDark : const Color(0xFFF8FAFC),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      onSubmitted: (_) => _sendAdminReply(supabase),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filled(
                                    onPressed: () => _sendAdminReply(supabase),
                                    icon: const Icon(Icons.send_rounded),
                                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                );

                if (isNarrow) {
                  return _selectedConvId != null ? chatPane : listPane;
                }

                return Row(
                  children: [
                    listPane,
                    const SizedBox(width: 16),
                    Expanded(child: chatPane),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAdminReply(dynamic supabase) async {
    final text = _chatInputCtrl.text.trim();
    final convId = _selectedConvId;
    if (text.isEmpty || convId == null) return;

    _chatInputCtrl.clear();
    const systemAdminId = '00000000-0000-0000-0000-000000000001';
    final now = DateTime.now();

    try {
      await supabase.from('messages').insert({
        'id': const Uuid().v4(),
        'conversation_id': convId,
        'sender_id': systemAdminId,
        'content': text,
        'status': 'sent',
        'type': 'text',
        'created_at': now.toIso8601String(),
      });

      await supabase.from('conversations').update({
        'last_message': text,
        'last_sender_id': systemAdminId,
        'last_message_at': now.toIso8601String(),
      }).eq('id', convId);

      if (_selectedUserId != null && _selectedUserId!.isNotEmpty) {
        await supabase.from('notifications').insert({
          'user_id': _selectedUserId,
          'title': 'تطبيق بيتك 🔵: رد جديد من الدعم',
          'body': text,
          'type': 'admin_direct_message',
          'read': false,
          'created_at': now.toIso8601String(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء إرسال الرد: $e')),
        );
      }
    }
  }
}
