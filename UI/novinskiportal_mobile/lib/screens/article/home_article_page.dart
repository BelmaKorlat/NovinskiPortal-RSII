import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/providers/category_articles_provider.dart';
import 'package:novinskiportal_mobile/widgets/app_main_app_bar.dart';
import 'package:novinskiportal_mobile/widgets/hamburger_menu.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/models/category_articles_models.dart';
import 'package:novinskiportal_mobile/models/article_models.dart';
import 'package:novinskiportal_mobile/utils/datetime_utils.dart';
import 'package:novinskiportal_mobile/core/api_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      return Scaffold(
        appBar: AppBar(title: const Text('Novinski portal'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null && provider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Novinski portal'), centerTitle: true),
        body: Center(
          child: Text(provider.error!, style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: MainAppBar(
        title: 'Novinski portal',
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onSearchTap: () {
          // ovdje će ići ekran za pretragu
          // npr. Navigator.push(...)
        },
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: provider.items.length,
          itemBuilder: (ctx, index) {
            final cat = provider.items[index];
            return HomeCategorySection(category: cat);
          },
        ),
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
                Text(
                  'Prikaži sve',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
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

      // if (i != articles.length - 1) {
      //   widgets.add(const SizedBox(height: 6));
      // }
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

class BigArticleCard extends StatelessWidget {
  final ArticleDto article;
  final Color categoryColor;

  const BigArticleCard({
    super.key,
    required this.article,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // detalji
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                ApiClient.resolveUrl(article.mainPhotoPath),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.subheadline.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.headline,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatRelative(article.publishedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.comment,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediumArticleCard extends StatelessWidget {
  final ArticleDto article;
  final Color categoryColor;

  const MediumArticleCard({
    super.key,
    required this.article,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // detalji
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2.2,
              child: Image.network(
                ApiClient.resolveUrl(article.mainPhotoPath),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.subheadline.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatRelative(article.publishedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.comment,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StandardArticleCard extends StatelessWidget {
  final ArticleDto article;

  const StandardArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final categoryColor = Color(
      int.parse(article.color.replaceFirst('#', '0xFF')),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  ApiClient.resolveUrl(article.mainPhotoPath),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.subheadline.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatRelative(article.publishedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.comment,
                          size: 14,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmallArticleCard extends StatelessWidget {
  final ArticleDto article;

  const SmallArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final categoryColor = Color(
      int.parse(article.color.replaceFirst('#', '0xFF')),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // detalji
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // manja slika
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  ApiClient.resolveUrl(article.mainPhotoPath),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),

              // tekst
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.subheadline.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      article.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formatRelative(article.publishedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
