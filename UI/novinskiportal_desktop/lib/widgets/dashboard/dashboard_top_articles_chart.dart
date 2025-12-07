import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import 'package:novinskiportal_desktop/models/admin_dashboard_models.dart';
import 'package:novinskiportal_desktop/providers/admin_dashboard_provider.dart';

class DashboardTopArticlesChart extends StatefulWidget {
  final List<DashboardCategoryViews> categoryStats;

  const DashboardTopArticlesChart({super.key, required this.categoryStats});

  @override
  State<DashboardTopArticlesChart> createState() =>
      _DashboardTopArticlesChartState();
}

class _DashboardTopArticlesChartState extends State<DashboardTopArticlesChart> {
  int? _selectedCategoryId;
  DateTime? _from;
  DateTime? _to;

  Future<void> _reload() async {
    await context.read<AdminDashboardProvider>().loadTopArticles(
      categoryId: _selectedCategoryId,
      from: _from,
      to: _to,
      take: 15,
    );
  }

  Future<void> _pickFrom() async {
    final now = DateTime.now();
    final initial = _from ?? now.subtract(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _from = picked;
      });
      await _reload();
    }
  }

  Future<void> _pickTo() async {
    final now = DateTime.now();
    final initial = _to ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _to = picked;
      });
      await _reload();
    }
  }

  Future<void> _exportReport() async {
    final provider = context.read<AdminDashboardProvider>();

    await provider.exportTopArticlesReport(
      categoryId: _selectedCategoryId,
      from: _from,
      to: _to,
      take: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final categories = <DashboardCategoryViews>[];
    final seen = <int>{};
    for (final item in widget.categoryStats) {
      if (seen.add(item.categoryId)) {
        categories.add(item);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategorija',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
                style: textTheme.bodyMedium,
                iconSize: 18,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sve kategorije'),
                  ),
                  ...categories.map((c) {
                    return DropdownMenuItem<int?>(
                      value: c.categoryId,
                      child: Text(
                        c.categoryName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (value) async {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                  await _reload();
                },
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              width: 120,
              child: _DateFilterButton(
                label: 'Od',
                date: _from,
                onTap: _pickFrom,
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              width: 120,
              child: _DateFilterButton(label: 'Do', date: _to, onTap: _pickTo),
            ),

            const Spacer(),

            TextButton.icon(
              onPressed: _exportReport,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                foregroundColor: cs.primary,
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Izvještaj'),
            ),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 180,
          child: () {
            if (provider.isTopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.topError != null) {
              return Center(
                child: Text(
                  provider.topError!,
                  style: TextStyle(color: cs.error),
                ),
              );
            }

            final items = provider.topArticles;
            return _TopArticlesBarChart(articles: items);
          }(),
        ),
      ],
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateFilterButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  String _format() {
    if (date == null) return label;
    return '${date!.day.toString().padLeft(2, '0')}.'
        '${date!.month.toString().padLeft(2, '0')}.'
        '${date!.year}.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Text(
        _format(),
        style: textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TopArticlesBarChart extends StatelessWidget {
  final List<DashboardTopArticle> articles;

  const _TopArticlesBarChart({required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(
        child: Text('Nema podataka o najčitanijim člancima.'),
      );
    }

    final top =
        (articles.toList()
              ..sort((a, b) => b.totalViews.compareTo(a.totalViews)))
            .take(15)
            .toList();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final maxViews = top
        .map((e) => e.totalViews)
        .fold<int>(0, (prev, v) => v > prev ? v : prev);

    final interval = _calcInterval(maxViews);
    final maxY = ((maxViews / interval).ceil() * interval).toDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => cs.surface.withValues(alpha: 0.95),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = top[group.x.toInt()];
              return BarTooltipItem(
                '${item.title}\n',
                textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Pregleda: ${item.totalViews}',
                    style: textTheme.bodySmall,
                  ),
                ],
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
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
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: List.generate(top.length, (index) {
          final item = top[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.totalViews.toDouble(),
                width: 14,
                borderRadius: BorderRadius.circular(4),
                color: cs.primary,
              ),
            ],
          );
        }),
      ),
    );
  }

  double _calcInterval(int maxViews) {
    if (maxViews <= 10) return 2;
    if (maxViews <= 50) return 10;
    if (maxViews <= 100) return 20;
    if (maxViews <= 200) return 40;
    if (maxViews <= 500) return 100;
    return 200;
  }
}
