import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_data_table.dart';

/// Dashboard overview with live stats and charts
class DashboardOverview extends ConsumerWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final users = ref.watch(usersStreamProvider);
    final properties = ref.watch(propertiesStreamProvider);
    final offices = ref.watch(officesStreamProvider);
    final reports = ref.watch(reportsStreamProvider);
    final subscriptions = ref.watch(subscriptionsStreamProvider);
    final payments = ref.watch(paymentsStreamProvider);

    final usersData = users.valueOrNull ?? [];
    final propsData = properties.valueOrNull ?? [];
    final officesData = offices.valueOrNull ?? [];
    final reportsData = reports.valueOrNull ?? [];
    final subsData = subscriptions.valueOrNull ?? [];
    final paymentsData = payments.valueOrNull ?? [];

    final pendingProps = propsData.where((p) => p['status'] == 'pending').toList();
    final activeProps = propsData.where((p) => p['status'] == 'active').toList();
    final pendingReports = reportsData.where((r) => r['status'] == 'pending').toList();
    final totalRevenue = paymentsData.where((p) => p['status'] == 'completed').fold<double>(0, (sum, p) => sum + ((p['amount'] ?? 0) as num).toDouble());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Page Header ───────────────────────────────────
          Text(
            'لوحة المعلومات',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          const Text(
            'نظرة عامة على أداء ومؤشرات المنصة العقارية - بيانات حقيقية',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 28),

          // ─── Stats Grid ────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 1100 ? 4 : constraints.maxWidth > 700 ? 3 : constraints.maxWidth > 450 ? 2 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.7,
                children: [
                  AdminStatCard(title: 'إجمالي المستخدمين', count: usersData.length, icon: Icons.people_rounded, color: AppColors.primary, isDark: isDark),
                  AdminStatCard(title: 'العقارات المدرجة', count: propsData.length, icon: Icons.home_rounded, color: AppColors.info, isDark: isDark, subtitle: '${activeProps.length} نشط'),
                  AdminStatCard(title: 'المكاتب المعتمدة', count: officesData.length, icon: Icons.business_rounded, color: AppColors.warning, isDark: isDark),
                  AdminStatCard(title: 'البلاغات المعلقة', count: pendingReports.length, icon: Icons.report_rounded, color: AppColors.error, isDark: isDark),
                  AdminStatCard(title: 'الاشتراكات النشطة', count: subsData.where((s) => s['status'] == 'active').length, icon: Icons.workspace_premium_rounded, color: const Color(0xFF8B5CF6), isDark: isDark),
                  AdminStatCard(title: 'إجمالي الإيرادات', count: totalRevenue.toInt(), icon: Icons.monetization_on_rounded, color: AppColors.success, isDark: isDark, subtitle: 'ج.م'),
                  AdminStatCard(title: 'عقارات معلقة', count: pendingProps.length, icon: Icons.pending_actions_rounded, color: const Color(0xFFEC4899), isDark: isDark),
                  AdminStatCard(title: 'مستخدمين جدد (اليوم)', count: _countToday(usersData), icon: Icons.person_add_rounded, color: const Color(0xFF0EA5E9), isDark: isDark),
                ],
              );
            },
          ),
          const SizedBox(height: 36),

          // ─── Charts Row ────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildPropertyTypeChart(propsData, isDark)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _buildPurposeChart(propsData, isDark)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildPropertyTypeChart(propsData, isDark),
                  const SizedBox(height: 20),
                  _buildPurposeChart(propsData, isDark),
                ],
              );
            },
          ),
          const SizedBox(height: 36),

          // ─── Pending Properties Table ──────────────────────
          const AdminSectionHeader(title: 'عقارات تنتظر المراجعة', accentColor: AppColors.warning),
          const SizedBox(height: 16),
          AdminDataTable(
            isDark: isDark,
            emptyMessage: 'لا توجد عقارات معلقة للمراجعة 🎉',
            columns: const [
              DataColumn(label: Text('العنوان')),
              DataColumn(label: Text('النوع')),
              DataColumn(label: Text('السعر')),
              DataColumn(label: Text('التاريخ')),
            ],
            rows: pendingProps.take(5).map((p) {
              return DataRow(cells: [
                DataCell(SizedBox(width: 180, child: Text(p['title'] ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)))),
                DataCell(Text(_typeAr(p['type'] ?? ''))),
                DataCell(Text('${_formatPrice(p['price'])} ج.م', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary))),
                DataCell(Text(_formatDate(p['created_at']), style: const TextStyle(fontSize: 12))),
              ]);
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  int _countToday(List<Map<String, dynamic>> items) {
    final today = DateTime.now();
    return items.where((item) {
      final created = DateTime.tryParse(item['created_at']?.toString() ?? '');
      return created != null && created.year == today.year && created.month == today.month && created.day == today.day;
    }).length;
  }

  Widget _buildPropertyTypeChart(List<Map<String, dynamic>> props, bool isDark) {
    final typeCounts = <String, int>{};
    for (final p in props) {
      final type = p['type']?.toString() ?? 'other';
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    final colors = [AppColors.primary, AppColors.info, const Color(0xFF6366F1), AppColors.warning, AppColors.error, const Color(0xFF8B5CF6), const Color(0xFFEC4899), AppColors.success];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('توزيع أنواع العقارات', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 20),
          if (typeCounts.isEmpty)
            const SizedBox(height: 160, child: Center(child: Text('لا توجد بيانات', style: TextStyle(color: AppColors.textSecondary))))
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (typeCounts.values.isEmpty ? 1 : typeCounts.values.reduce((a, b) => a > b ? a : b)).toDouble() * 1.3,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)))),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final keys = typeCounts.keys.toList();
                          if (v.toInt() >= keys.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_typeAr(keys[v.toInt()]), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: isDark ? AppColors.borderDark : AppColors.borderLight, strokeWidth: 0.5)),
                  borderData: FlBorderData(show: false),
                  barGroups: typeCounts.entries.toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: colors[i % colors.length],
                        width: 20,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurposeChart(List<Map<String, dynamic>> props, bool isDark) {
    final saleCount = props.where((p) => p['purpose'] == 'sale').length;
    final rentCount = props.where((p) => p['purpose'] == 'rent').length;
    final total = saleCount + rentCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('البيع مقابل الإيجار', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 20),
          if (total == 0)
            const SizedBox(height: 160, child: Center(child: Text('لا توجد بيانات', style: TextStyle(color: AppColors.textSecondary))))
          else
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: saleCount.toDouble(),
                      title: '${(saleCount / total * 100).toStringAsFixed(0)}%',
                      color: AppColors.forSale,
                      radius: 40,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: rentCount.toDouble(),
                      title: '${(rentCount / total * 100).toStringAsFixed(0)}%',
                      color: AppColors.forRent,
                      radius: 40,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem('للبيع', AppColors.forSale, saleCount),
              _legendItem('للإيجار', AppColors.forRent, rentCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ],
    );
  }

  String _typeAr(String type) {
    const map = {'apartment': 'شقة', 'villa': 'فيلا', 'duplex': 'دوبلكس', 'penthouse': 'بنتهاوس', 'studio': 'استوديو', 'shop': 'محل', 'office': 'مكتب', 'clinic': 'عيادة', 'land': 'أرض', 'warehouse': 'مخزن', 'factory': 'مصنع', 'farm': 'مزرعة', 'commercial': 'تجاري', 'administrative': 'إداري'};
    return map[type] ?? type;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final n = (price as num).toDouble();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    final date = DateTime.tryParse(d.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
