import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/utils/datetime_utils.dart';
import 'package:novinskiportal_mobile/core/api_client.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:provider/provider.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      final p = context.read<ArticleProvider>();
      p.page = 0;
      p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 1) prvo učitavanje
    if (provider.isLoading && provider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Novinski portal'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2) greška i nema podataka
    if (provider.error != null && provider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Novinski portal'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  provider.page = 0;
                  provider.load();
                },
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    // 3) normalno stanje
    return Scaffold(
      appBar: AppBar(title: const Text('Novinski portal'), centerTitle: true),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            provider.page = 0;
            await provider.load();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final article = provider.items[index];
              return _ArticleCard(article: article);
            },
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ArticleDto article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final categoryColor = Color(
      int.parse(article.color.replaceFirst('#', '0xFF')),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? BorderSide(color: Colors.white.withValues(alpha: 0.10))
            : BorderSide.none,
      ),
      elevation: isDark ? 0 : 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // ovdje ćemo kasnije otvoriti detalje članka
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  ApiClient.resolveUrl(article.mainPhotoPath),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // desno tekst
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // kategorija
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: cs.primary.withValues(alpha: 0.12),
                    //     borderRadius: BorderRadius.circular(16),
                    //   ),
                    //   child: Text(
                    //     article.category,
                    //     style: theme.textTheme.labelSmall?.copyWith(
                    //       fontWeight: FontWeight.w600,
                    //       color: cs.primary,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 6),

                    // podnaslov
                    Text(
                      article.subheadline.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // naslov
                    Text(
                      article.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // donji red: datum i autor
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
