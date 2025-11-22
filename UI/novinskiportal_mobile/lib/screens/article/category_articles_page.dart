import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/widgets/article/big_article_card.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/providers/article/category_feed_provider.dart';

class CategoryArticlesPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final Color categoryColor;

  const CategoryArticlesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<CategoryArticlesPage> createState() => _CategoryArticlesPageState();
}

class _CategoryArticlesPageState extends State<CategoryArticlesPage> {
  late final ScrollController _scrollController;
  late final PageController _pageController;
  int _currentPage = 0;

  void onSearchTap() {
    // za sada samo placeholder
    // kasnije ovdje otvoriš search za članke
    // npr. Navigator.of(context).push(...);
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    //  _pageController = PageController();
    _pageController = PageController(viewportFraction: 0.9);

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CategoryFeedProvider>();
      provider.loadInitial();
    });
  }

  void _onScroll() {
    final provider = context.read<CategoryFeedProvider>();

    if (!_scrollController.hasClients) return;

    if (!provider.hasMore || provider.isLoading) return;

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= max - 300) {
      provider.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryFeedProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cardWidth = MediaQuery.of(context).size.width - 24;
    final imageHeight = cardWidth / 2.1;
    final carouselHeight = imageHeight + 140;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryName.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: onSearchTap),
        ],
      ),

      body: Builder(
        builder: (context) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.error!,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => provider.loadInitial(),
                      child: const Text('Pokušaj ponovo'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadInitial,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (provider.items.length >= 3) ...[
                  SizedBox(
                    height: carouselHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final article = provider.items[index];
                        return BigArticleCard(
                          article: article,
                          categoryColor: widget.categoryColor,
                          // onTap: () { /* detalji članka kasnije */ },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // indikator tačkica
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final selected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: selected ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: selected
                                ? cs.onSurface
                                : cs.onSurface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                ..._buildStandardList(provider),

                if (provider.hasMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStandardList(CategoryFeedProvider provider) {
    final widgets = <Widget>[];

    final startIndex = provider.items.length >= 3 ? 3 : 0;

    for (var i = startIndex; i < provider.items.length; i++) {
      final article = provider.items[i];
      widgets.add(
        StandardArticleCard(
          article: article,
          // onTap: () { /* detalji članka kasnije */ },
        ),
      );
    }

    return widgets;
  }
}
