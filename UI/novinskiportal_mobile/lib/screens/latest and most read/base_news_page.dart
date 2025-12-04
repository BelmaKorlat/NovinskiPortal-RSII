import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/models/article/news_mode.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:novinskiportal_mobile/providers/article/news_provider.dart';
import 'package:novinskiportal_mobile/screens/article/article_detail_page.dart';
import 'package:novinskiportal_mobile/widgets/article/medium_article_card.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';
import 'package:novinskiportal_mobile/widgets/common/top_tabs.dart';
import 'package:provider/provider.dart';

abstract class BaseNewsPage extends StatefulWidget {
  final NewsMode initialMode;
  final ValueChanged<NewsMode>? onModeChanged;

  const BaseNewsPage({
    super.key,
    required this.initialMode,
    this.onModeChanged,
  });
}

abstract class BaseNewsPageState<T extends BaseNewsPage> extends State<T>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  int _topIndex = 0;

  @override
  void initState() {
    super.initState();
    _topIndex = _indexFromMode(widget.initialMode);

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      if (!mounted) return;
      final provider = context.read<NewsProvider>();
      provider.changeMode(widget.initialMode);
      provider.loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  int _indexFromMode(NewsMode mode) {
    switch (mode) {
      case NewsMode.latest:
        return 0;
      case NewsMode.mostread:
        return 1;
    }
  }

  NewsMode _modeFromIndex(int index) {
    switch (index) {
      case 0:
        return NewsMode.latest;
      case 1:
        return NewsMode.mostread;
      default:
        return NewsMode.latest;
    }
  }

  void _onScroll() {
    final provider = context.read<NewsProvider>();

    if (!_scrollController.hasClients) return;
    if (!provider.hasMore || provider.isLoading) return;

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= max - 300) {
      provider.loadMore();
    }
  }

  void _onTopChanged(int index) {
    if (index == _topIndex) return;

    setState(() {
      _topIndex = index;
    });

    final newMode = _modeFromIndex(index);
    final provider = context.read<NewsProvider>();

    provider.changeMode(newMode);

    widget.onModeChanged?.call(newMode);
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

  List<Widget> _buildArticles(BuildContext context, NewsProvider provider) {
    final widgets = <Widget>[];
    final articles = provider.items;

    for (var i = 0; i < articles.length; i++) {
      final a = articles[i];

      if (i == 0) {
        widgets.add(
          MediumArticleCard(
            article: a,
            categoryColor: Theme.of(context).colorScheme.primary,
            onTap: () => _openArticleDetail(a),
          ),
        );
      } else {
        widgets.add(
          StandardArticleCard(article: a, onTap: () => _openArticleDetail(a)),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final provider = context.watch<NewsProvider>();

    Widget listContent;

    if (provider.isLoading && provider.items.isEmpty) {
      listContent = const Center(child: CircularProgressIndicator());
    } else if (provider.error != null && provider.items.isEmpty) {
      listContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            provider.error!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      listContent = RefreshIndicator(
        onRefresh: provider.loadInitial,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            ..._buildArticles(context, provider),
            if (provider.hasMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TopTabs(
          currentIndex: _topIndex,
          labels: const ['Najnovije', 'Najčitanije'],
          onChanged: _onTopChanged,
        ),
        const SizedBox(height: 8),
        Expanded(child: listContent),
      ],
    );
  }
}
