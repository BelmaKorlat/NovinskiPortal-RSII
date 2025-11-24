import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/providers/favorite/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/models/favorite/favorite_models.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:novinskiportal_mobile/screens/article/article_detail_page.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<FavoriteListPage> createState() => FavoriteListPageState();
}

class FavoriteListPageState extends State<FavoriteListPage> {
  bool _initialized = false;
  bool _selectionMode = false;
  final Set<int> _selectedIds = <int>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<FavoritesProvider>().load();
    }
  }

  void enterSelectionMode() {
    if (!_selectionMode && mounted) {
      setState(() {
        _selectionMode = true;
        _selectedIds.clear();
      });
    }
  }

  void _exitSelectionMode() {
    if (_selectionMode && mounted) {
      setState(() {
        _selectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  bool _areAllSelected(FavoritesProvider favs) {
    if (favs.items.isEmpty) return false;
    return _selectedIds.length == favs.items.length;
  }

  Future<void> _deleteSelected(FavoritesProvider favs) async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obrisati odabrane članke?'),
        content: const Text('Označeni članci će biti uklonjeni iz favorita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      _exitSelectionMode();
      return;
    }

    final ids = List<int>.from(_selectedIds);
    for (final id in ids) {
      await favs.removeFavorite(id);
    }

    _exitSelectionMode();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Odabrani članci su obrisani iz favorita.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (favs.isLoading && favs.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favs.error != null && favs.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            favs.error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (favs.items.isEmpty) {
      if (_selectionMode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _exitSelectionMode();
        });
      }

      return Center(
        child: Text(
          'Nemate spremljenih članaka.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_selectionMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Checkbox(
                  value: _areAllSelected(favs),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds
                          ..clear()
                          ..addAll(favs.items.map((f) => f.articleId));
                      } else {
                        _selectedIds.clear();
                      }
                    });
                  },
                ),
                const Text('Označi sve'),
                const Spacer(),
                TextButton.icon(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _deleteSelected(favs),
                  icon: const Icon(Icons.delete),
                  label: const Text('Obriši'),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => favs.load(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: favs.items.length,
              itemBuilder: (ctx, index) {
                final FavoriteDto fav = favs.items[index];
                final ArticleDto article = fav.article;
                final bool selected = _selectedIds.contains(article.id);

                return Stack(
                  children: [
                    StandardArticleCard(
                      article: article,
                      onTap: () async {
                        if (_selectionMode) {
                          setState(() {
                            if (selected) {
                              _selectedIds.remove(article.id);
                            } else {
                              _selectedIds.add(article.id);
                            }
                          });
                          return;
                        }

                        final articleProvider = context.read<ArticleProvider>();

                        try {
                          final detail = await articleProvider.getDetail(
                            article.id,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ArticleDetailPage(article: detail),
                            ),
                          );
                        } catch (_) {}
                      },
                    ),
                    if (_selectionMode)
                      Positioned(
                        right: 24,
                        top: 8,
                        child: Checkbox(
                          value: selected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedIds.add(article.id);
                              } else {
                                _selectedIds.remove(article.id);
                              }
                            });
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
