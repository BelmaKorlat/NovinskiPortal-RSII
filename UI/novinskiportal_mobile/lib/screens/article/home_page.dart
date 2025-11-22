import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/providers/article/category_articles_provider.dart';
import 'package:novinskiportal_mobile/providers/article/category_feed_provider.dart';
import 'package:novinskiportal_mobile/screens/article/category_articles_page.dart';
import 'package:novinskiportal_mobile/widgets/article/medium_article_card.dart';
import 'package:novinskiportal_mobile/widgets/article/small_article_card.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/models/category/category_articles_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _topTabIndex = -1;

  void resetTopTabs() {
    setState(() {
      _topTabIndex = -1;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CategoryArticlesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryArticlesProvider>();
    final theme = Theme.of(context);

    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.items.isEmpty) {
      return Center(
        child: Text(provider.error!, style: theme.textTheme.bodyMedium),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: provider.items.length + 1,
        itemBuilder: (ctx, index) {
          if (index == 0) {
            return TopTabs(
              currentIndex: _topTabIndex,
              labels: const ['Najnovije', 'Najčitanije', 'Uživo'],
              onChanged: (i) {
                if (i == 0) {
                  // Najnovije -> otvori novi screen
                  Navigator.pushNamed(context, '/latestNews');
                }

                // Najčitanije i Uživo ćemo dodati kasnije
                // if (i == 1) { ... }
                // if (i == 2) { ... }

                // ovdje kasnije ide navigacija ili promjena query-a
              },
            );
          }

          final cat = provider.items[index - 1];
          return HomeCategorySection(category: cat);
        },
      ),
    );
  }
}

class HomeCategorySection extends StatelessWidget {
  final CategoryArticlesDto category;

  const HomeCategorySection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header kategorije
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  category.name.toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _parseColor(category.color, cs.primary),
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    final color = _parseColor(category.color, cs.primary);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) =>
                              CategoryFeedProvider(categoryId: category.id),
                          child: CategoryArticlesPage(
                            categoryId: category.id,
                            categoryName: category.name,
                            categoryColor: color,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Prikaži sve',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._buildArticles(context),
        ],
      ),
    );
  }

  List<Widget> _buildArticles(BuildContext context) {
    final widgets = <Widget>[];
    final articles = category.articles;

    for (var i = 0; i < articles.length; i++) {
      final a = articles[i];

      if (i == 0) {
        widgets.add(
          MediumArticleCard(
            article: a,
            categoryColor: _parseColor(
              category.color,
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      } else if (i == 1 || i == 2) {
        widgets.add(StandardArticleCard(article: a));
      } else {
        widgets.add(SmallArticleCard(article: a));
      }
    }

    return widgets;
  }

  Color _parseColor(String hex, Color fallback) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }
}

class TopTabs extends StatelessWidget {
  final int currentIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const TopTabs({
    super.key,
    required this.currentIndex,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final baseStyle =
        theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14);

    double measureTextWidth(String text) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: baseStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.size.width;
    }

    Widget buildTab(String label, int index) {
      final selected = currentIndex == index;
      final width = measureTextWidth(label);

      return GestureDetector(
        onTap: () => onChanged(index),
        child: Padding(
          padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 3,
                width: width,
                color: selected ? cs.onSurface : Colors.transparent,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: baseStyle.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: SizedBox(
        height: 36,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(height: 2, color: cs.outlineVariant),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < labels.length; i++)
                    buildTab(labels[i], i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
