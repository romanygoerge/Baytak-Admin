import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/dashboard_overview.dart';
import '../widgets/users_management.dart';
import '../widgets/properties_management.dart';
import '../widgets/offices_management.dart';
import '../widgets/reports_management.dart';
import '../widgets/subscriptions_management.dart';
import '../widgets/payments_management.dart';
import '../widgets/notifications_management.dart';
import '../widgets/areas_management.dart';
import '../widgets/activity_logs_view.dart';

/// Professional Admin Dashboard Screen
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardOverview(),
    UsersManagement(),
    PropertiesManagement(),
    OfficesManagement(),
    ReportsManagement(),
    SubscriptionsManagement(),
    PaymentsManagement(),
    NotificationsManagement(),
    AreasManagement(),
    ActivityLogsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 960;

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              title: Text(
                AdminSidebar.menuItems[_selectedIndex].title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
      drawer: isWide
          ? null
          : Drawer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) => setState(() => _selectedIndex = index),
                isDark: isDark,
                isDrawer: true,
              ),
            ),
      body: isWide
          ? Row(
              children: [
                // Side Navigation Panel
                SizedBox(
                  width: 260,
                  child: AdminSidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) => setState(() => _selectedIndex = index),
                    isDark: isDark,
                    isDrawer: false,
                  ),
                ),
                // Main Content Window
                Expanded(
                  child: Container(
                    color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
    );
  }
}
