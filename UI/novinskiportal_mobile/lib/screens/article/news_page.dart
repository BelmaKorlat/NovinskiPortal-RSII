import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/models/article/news_mode.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:novinskiportal_mobile/providers/article/news_provider.dart';
import 'package:novinskiportal_mobile/screens/article/article_detail_page.dart';
import 'package:novinskiportal_mobile/screens/main/news_tabs_layout.dart';
import 'package:novinskiportal_mobile/widgets/article/medium_article_card.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPage();
}

class _NewsPage extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<NewsProvider>().loadInitial();
    });
  }

  int _indexFromMode(NewsMode mode) {
    switch (mode) {
      case NewsMode.latest:
        return 0;
      case NewsMode.mostread:
        return 1;
      case NewsMode.live:
        return 2;
    }
  }

  NewsMode _modeFromIndex(int index) {
    switch (index) {
      case 0:
        return NewsMode.latest;
      case 1:
        return NewsMode.mostread;
      case 2:
        return NewsMode.live;
      default:
        return NewsMode.latest;
    }
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
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    final provider = context.watch<NewsProvider>();

    final mode = provider.mode;
    final currentIndex = _indexFromMode(mode);

    Widget content;

    if (provider.isLoading && provider.items.isEmpty) {
      content = const Center(child: CircularProgressIndicator());
    } else if (provider.error != null && provider.items.isEmpty) {
      content = Center(
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
      content = RefreshIndicator(
        onRefresh: provider.loadInitial,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: _buildArticles(context, provider),
        ),
      );
    }

    return NewsTabsLayout(
      title: _titleForMode(mode),
      currentTopIndex: currentIndex,
      topLabels: const ['Najnovije', 'Najčitanije', 'Uživo'],
      onTopChanged: (i) {
        final newMode = _modeFromIndex(i);
        context.read<NewsProvider>().changeMode(newMode);
      },
      child: content,
    );
  }

  String _titleForMode(NewsMode mode) {
    switch (mode) {
      case NewsMode.latest:
        return 'Najnovije';
      case NewsMode.mostread:
        return 'Najčitanije';
      case NewsMode.live:
        return 'Uživo';
    }
  }
}
