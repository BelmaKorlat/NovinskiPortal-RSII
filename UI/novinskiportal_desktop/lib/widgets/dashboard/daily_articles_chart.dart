import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/models/admin_dashboard_models.dart';

class DailyArticlesChart extends StatelessWidget {
  final List<DashboardDailyArticles> items;

  const DailyArticlesChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Nema podataka o broju članaka.'));
    }

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lineColor = isDark ? const Color(0xFF4FC3F7) : cs.primary;

    final areaColor = isDark
        ? const Color(0x334FC3F7)
        : cs.primary.withValues(alpha: 0.25);

    final gridColor = isDark
        ? const Color(0xFF37474F)
        : cs.outlineVariant.withValues(alpha: 0.6);

    final data = [...items]..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].totalArticles.toDouble()));
    }

    final maxVal = data
        .map((e) => e.totalArticles)
        .fold<int>(0, (prev, v) => v > prev ? v : prev);

    final interval = _calcInterval(maxVal);
    final maxY = ((maxVal / interval).ceil() * interval).toDouble();

    final step = _calcStep(data.length);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY > 0 ? maxY : 1,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpots) =>
                cs.surface.withValues(alpha: 0.95),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final item = data[index];
                final dateLabel =
                    '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';

                return LineTooltipItem(
                  '$dateLabel\n',
                  textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Članaka: ${item.totalArticles}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toInt().toString(),
                    style: textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }

                if (index % step != 0) {
                  return const SizedBox.shrink();
                }

                final d = data[index].date;
                final label =
                    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(label, style: textTheme.bodySmall),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: areaColor),
          ),
        ],
      ),
    );
  }

  double _calcInterval(int maxVal) {
    if (maxVal <= 2) return 1;
    if (maxVal <= 5) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 4;
    return 5;
  }

  int _calcStep(int length) {
    if (length <= 7) return 1;
    if (length <= 14) return 2;
    if (length <= 30) return 5;
    return 7;
  }
}
