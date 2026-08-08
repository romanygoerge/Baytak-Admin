import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Admin sidebar / drawer with navigation items
class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isDark;
  final bool isDrawer;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDark,
    this.isDrawer = false,
  });

  static const List<AdminSidebarMenuItem> menuItems = [
    AdminSidebarMenuItem('لوحة المعلومات', Icons.dashboard_rounded, Color(0xFF0D9488)),
    AdminSidebarMenuItem('إدارة المستخدمين', Icons.people_rounded, Color(0xFF3B82F6)),
    AdminSidebarMenuItem('إدارة العقارات', Icons.home_rounded, Color(0xFF6366F1)),
    AdminSidebarMenuItem('إدارة المكاتب', Icons.business_rounded, Color(0xFFF59E0B)),
    AdminSidebarMenuItem('البلاغات والشكاوى', Icons.report_rounded, Color(0xFFEF4444)),
    AdminSidebarMenuItem('باقات الاشتراك', Icons.workspace_premium_rounded, Color(0xFF8B5CF6)),
    AdminSidebarMenuItem('سجل المدفوعات', Icons.payment_rounded, Color(0xFF22C55E)),
    AdminSidebarMenuItem('إرسال الإشعارات', Icons.notifications_rounded, Color(0xFF0EA5E9)),
    AdminSidebarMenuItem('إدارة المناطق', Icons.location_city_rounded, Color(0xFFEC4899)),
    AdminSidebarMenuItem('سجلات النظام', Icons.list_alt_rounded, Color(0xFF64748B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF0B0F19) : const Color(0xFF0F172A),
      child: Column(
        children: [
          // ─── Header ─────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, isDrawer ? 60 : 40, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بيتك أدمن',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'لوحة التحكم الإدارية',
                        style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          ),
          const SizedBox(height: 12),

          // ─── Menu Items ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        onItemSelected(index);
                        if (isDrawer) Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    item.color.withValues(alpha: 0.2),
                                    item.color.withValues(alpha: 0.05),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: item.color.withValues(alpha: 0.3), width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? item.color : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white54,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: item.color.withValues(alpha: 0.5), blurRadius: 8),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Footer ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.primaryDark, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المسؤول', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('admin@baytak.app', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSidebarMenuItem {
  final String title;
  final IconData icon;
  final Color color;
  const AdminSidebarMenuItem(this.title, this.icon, this.color);
}
