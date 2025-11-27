import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/api_client.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:novinskiportal_mobile/providers/favorite/favorite_provider.dart';
import 'package:novinskiportal_mobile/screens/article_comment/article_comment_list_page.dart';
import 'package:novinskiportal_mobile/utils/color_utils.dart';
import 'package:novinskiportal_mobile/utils/datetime_utils.dart';
import 'package:provider/provider.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleDetailDto article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool _isFavorite = false;
  late ArticleDetailDto _article;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    Future.microtask(() {
      if (!mounted) return;
      final favorites = context.read<FavoritesProvider>();
      final isFavorite = favorites.isFavorite(widget.article.id);
      setState(() {
        _isFavorite = isFavorite;
      });
    });
  }

  Future<void> _reloadArticle() async {
    final articleProvider = context.read<ArticleProvider>();

    try {
      final fresh = await articleProvider.getDetail(_article.id);
      if (!mounted) return;

      setState(() {
        _article = fresh;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final article = _article;

    final categoryColor = tryParseHexColor(article.color) ?? cs.primary;

    final commentsCount = article.commentsCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            children: [
              const TextSpan(text: 'Novinski portal - '),
              TextSpan(
                text: article.category,
                style: TextStyle(color: categoryColor),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reloadArticle,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          ApiClient.resolveUrl(article.mainPhotoPath),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stack) {
                            return Container(
                              color: cs.onSurface,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: cs.onSurface.withValues(alpha: 0.4),
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: cs.surface.withValues(alpha: 0.9),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              _isFavorite
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: cs.primary,
                            ),
                            onPressed: () async {
                              final favorites = context
                                  .read<FavoritesProvider>();

                              final nowFavorite = await favorites
                                  .toggleFavorite(widget.article.id);

                              setState(() {
                                _isFavorite = nowFavorite;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    nowFavorite
                                        ? 'Članak je spremljen u favorite.'
                                        : 'Članak je uklonjen iz favorita.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  article.subheadline.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  article.headline,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.user,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatRelative(article.publishedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ArticleCommentListPage(
                              articleId: article.id,
                              headline: article.headline,
                              categoryColor: categoryColor,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                          if (commentsCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              article.commentsCount.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // kratki tekst
                Text(
                  article.shortText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                Divider(color: cs.outlineVariant),

                const SizedBox(height: 16),

                // glavni tekst
                Text(
                  article.text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),

                const SizedBox(height: 24),

                // dodatne slike
                if (article.additionalPhotos.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Galerija',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: article.additionalPhotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (ctx, index) {
                            final url = ApiClient.resolveUrl(
                              article.additionalPhotos[index],
                            );
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, error, stack) {
                                    return Container(
                                      width: 160,
                                      color: cs.onSurface,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: cs.onSurface.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
