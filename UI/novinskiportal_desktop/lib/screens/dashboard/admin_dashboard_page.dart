import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/widgets/dashboard/dashboard_top_articles_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/providers/admin_dashboard_provider.dart';
import 'package:novinskiportal_desktop/widgets/dashboard/daily_articles_chart.dart';
import 'package:novinskiportal_desktop/widgets/dashboard/category_views_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final summary = provider.summary;
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (provider.isLoading && summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && summary == null) {
      return Center(child: Text(provider.error!));
    }

    if (summary == null) {
      return const Center(child: Text('Nema podataka za dashboard.'));
    }

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1400;

    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Početna',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pregled stanja portala',
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 6),
                  Text(
                    today,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (isWide)
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.article_outlined,
                    iconColor: cs.primary,
                    label: 'Ukupan broj članaka',
                    value: summary.totalArticles.toString(),
                    subtitle: 'Sve objave na portalu',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_alt_outlined,
                    iconColor: cs.secondary,
                    label: 'Ukupan broj korisnika',
                    value: summary.totalUsers.toString(),
                    subtitle: 'Registrovani korisnici',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.visibility_outlined,
                    iconColor: cs.tertiary,
                    label: 'Pregledi u zadnjih 7 dana',
                    value: summary.viewsLast7Days.toString(),
                    subtitle: 'Sve posjete u tom periodu',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month_outlined,
                    iconColor: cs.error,
                    label: 'Novi članci u zadnjih 7 dana',
                    value: summary.newArticlesLast7Days.toString(),
                    subtitle: 'Objavljeno u zadnjih 7 dana',
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _StatCard(
                  icon: Icons.article_outlined,
                  iconColor: cs.primary,
                  label: 'Ukupan broj članaka',
                  value: summary.totalArticles.toString(),
                  subtitle: 'Sve objave na portalu',
                ),
                const SizedBox(height: 12),
                _StatCard(
                  icon: Icons.people_alt_outlined,
                  iconColor: cs.secondary,
                  label: 'Ukupan broj korisnika',
                  value: summary.totalUsers.toString(),
                  subtitle: 'Registrovani korisnici',
                ),
                const SizedBox(height: 12),
                _StatCard(
                  icon: Icons.visibility_outlined,
                  iconColor: cs.tertiary,
                  label: 'Pregledi u zadnjih 7 dana',
                  value: summary.viewsLast7Days.toString(),
                  subtitle: 'Sve posjete u tom periodu',
                ),
                const SizedBox(height: 12),
                _StatCard(
                  icon: Icons.calendar_month_outlined,
                  iconColor: cs.error,
                  label: 'Novi članci u zadnjih 7 dana',
                  value: summary.newArticlesLast7Days.toString(),
                  subtitle: 'Objavljeno u zadnjih 7 dana',
                ),
              ],
            ),

          const SizedBox(height: 24),

          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _DashboardPanel(
                    title: 'Top 15 najčitanijih članaka',
                    child: SizedBox(
                      height: 260,
                      child: DashboardTopArticlesChart(
                        categoryStats: summary.categoryViewsLast30Days,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _DashboardPanel(
                    title: 'Čitanost po kategorijama (zadnjih 30 dana)',
                    action: TextButton.icon(
                      onPressed: () {
                        context
                            .read<AdminDashboardProvider>()
                            .exportCategoryViewsReport();
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Izvještaj'),
                    ),
                    child: SizedBox(
                      height: 250,
                      child: CategoryViewsChart(
                        items: summary.categoryViewsLast30Days,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _DashboardPanel(
                  title: 'Top 15 najčitanijih članaka',
                  child: SizedBox(
                    height: 260,
                    child: DashboardTopArticlesChart(
                      categoryStats: summary.categoryViewsLast30Days,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _DashboardPanel(
                  title: 'Čitanost po kategorijama (zadnjih 30 dana)',
                  action: TextButton.icon(
                    onPressed: () {
                      context
                          .read<AdminDashboardProvider>()
                          .exportCategoryViewsReport();
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Izvještaj'),
                  ),
                  child: SizedBox(
                    height: 260,
                    child: CategoryViewsChart(
                      items: summary.categoryViewsLast30Days,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          _DashboardPanel(
            title: 'Broj članaka po danima (zadnjih 30 dana)',
            child: SizedBox(
              height: 260,
              child: DailyArticlesChart(items: summary.dailyArticlesLast30Days),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _DashboardPanel({
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (action != null) ...[const SizedBox(width: 8), action!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
