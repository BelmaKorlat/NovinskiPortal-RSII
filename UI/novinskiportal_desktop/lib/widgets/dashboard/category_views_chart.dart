import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:novinskiportal_desktop/models/admin_dashboard_models.dart';

class CategoryViewsChart extends StatelessWidget {
  final List<DashboardCategoryViews> items;

  const CategoryViewsChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Nema podataka o čitanosti po kategorijama.'),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final nonEmpty = items.where((e) => e.totalViews > 0).toList();
    if (nonEmpty.isEmpty) {
      return const Center(
        child: Text('Nema podataka o čitanosti po kategorijama.'),
      );
    }

    final total = nonEmpty.fold<int>(0, (sum, e) => sum + e.totalViews);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = isDark
        ? const [
            Color(0xFF42A5F5),
            Color(0xFFAB47BC),
            Color(0xFFFFCA28),
            Color(0xFF26A69A),
            Color(0xFFEF5350),
            Color(0xFF7E57C2),
            Color(0xFFFF7043),
          ]
        : [
            cs.primary,
            cs.secondary,
            cs.tertiary,
            Colors.orange,
            Colors.teal,
            Colors.pink,
            Colors.indigo,
          ];
    final sections = <PieChartSectionData>[];

    for (var i = 0; i < nonEmpty.length; i++) {
      final item = nonEmpty[i];
      final percent = total == 0 ? 0.0 : (item.totalViews / total * 100);

      sections.add(
        PieChartSectionData(
          value: item.totalViews.toDouble(),
          color: colors[i % colors.length],
          title: '${percent.toStringAsFixed(0)}%',
          radius: 70,
          titleStyle: textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < nonEmpty.length; i++)
                  _LegendItem(
                    color: colors[i % colors.length],
                    name: nonEmpty[i].categoryName,
                    views: nonEmpty[i].totalViews,
                    percent: total == 0
                        ? 0
                        : (nonEmpty[i].totalViews * 100 ~/ total),
                    textTheme: textTheme,
                    cs: cs,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String name;
  final int views;
  final int percent;
  final TextTheme textTheme;
  final ColorScheme cs;

  const _LegendItem({
    required this.color,
    required this.name,
    required this.views,
    required this.percent,
    required this.textTheme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$views',
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($percent%)',
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
