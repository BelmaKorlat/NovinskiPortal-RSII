import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/models/article/news_mode.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:novinskiportal_mobile/providers/article/category_articles_provider.dart';
import 'package:novinskiportal_mobile/providers/article/articles_feed_provider.dart';
import 'package:novinskiportal_mobile/screens/article/article_detail_page.dart';
import 'package:novinskiportal_mobile/screens/article/articles_feed_page.dart';
import 'package:novinskiportal_mobile/utils/color_utils.dart';
import 'package:novinskiportal_mobile/widgets/article/medium_article_card.dart';
import 'package:novinskiportal_mobile/widgets/article/small_article_card.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';
import 'package:novinskiportal_mobile/widgets/common/top_tabs.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/models/category/category_articles_models.dart';

class HomePage extends StatefulWidget {
  final void Function(NewsMode mode) onOpenNewsTab;
  const HomePage({super.key, required this.onOpenNewsTab});
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

  Future<void> _openArticleDetail(ArticleDto article) async {
    final articleProvider = context.read<ArticleProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await articleProvider.getDetail(article.id);

      if (!mounted) return;
      Navigator.of(context).pop();

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ArticleDetailPage(article: detail)),
      );
    } on ApiException catch (ex) {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ex.message)));
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška pri učitavanju članka.')),
      );
    }
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
              labels: const ['Najnovije', 'Najčitanije'],
              onChanged: (i) {
                setState(() {
                  _topTabIndex = i;
                });

                if (i == 0) {
                  widget.onOpenNewsTab(NewsMode.latest);
                } else if (i == 1) {
                  widget.onOpenNewsTab(NewsMode.mostread);
                }
              },
            );
          }

          final cat = provider.items[index - 1];
          return HomeCategorySection(
            category: cat,
            onArticleTap: _openArticleDetail,
          );
        },
      ),
    );
  }
}

class HomeCategorySection extends StatelessWidget {
  final CategoryArticlesDto category;
  final void Function(ArticleDto) onArticleTap;

  const HomeCategorySection({
    super.key,
    required this.category,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  category.name.toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        tryParseHexColor(category.color) ??
                        Theme.of(context).colorScheme.primary,

                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    final color =
                        tryParseHexColor(category.color) ??
                        Theme.of(context).colorScheme.primary;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) =>
                              ArticlesFeedProvider(categoryId: category.id),
                          child: ArticlesFeedPage(
                            title: category.name,
                            accentColor: color,
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
          MediumArticleCard(article: a, onTap: () => onArticleTap(a)),
        );
      } else if (i == 1 || i == 2) {
        widgets.add(
          StandardArticleCard(article: a, onTap: () => onArticleTap(a)),
        );
      } else {
        widgets.add(SmallArticleCard(article: a, onTap: () => onArticleTap(a)));
      }
    }

    return widgets;
  }
}
