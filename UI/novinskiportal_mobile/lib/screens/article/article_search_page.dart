import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/screens/article/article_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';

class ArticleSearchPage extends StatefulWidget {
  const ArticleSearchPage({super.key});

  @override
  State<ArticleSearchPage> createState() => _ArticleSearchPageState();
}

class _ArticleSearchPageState extends State<ArticleSearchPage> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;
  bool _initialLoaded = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ArticleProvider>();

      await provider.load();

      if (!mounted) return;
      setState(() {
        _initialLoaded = true;
      });
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(String value) async {
    final provider = context.read<ArticleProvider>();
    final query = value.trim();

    if (query.isEmpty) {
      provider.clear();
      await provider.load();
      setState(() {
        _submitted = false;
      });
      return;
    }

    await provider.search(query);
    setState(() {
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();
    final cs = Theme.of(context).colorScheme;

    final items = provider.items;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        iconTheme: IconThemeData(color: cs.onSurface),
        titleSpacing: 0,
        title: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Pretražite'),
            textInputAction: TextInputAction.search,
            onSubmitted: _onSubmit,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && !_initialLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_submitted && items.isEmpty && !provider.isLoading) {
            return const Center(child: Text('Nema rezultata za zadani upit.'));
          }

          if (!_submitted && items.isEmpty && !provider.isLoading) {
            return const Center(child: Text('Trenutno nema članaka.'));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200 &&
                  !provider.isLoading &&
                  provider.page < provider.lastPage) {
                provider.loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ArticleDto article = items[index];
                return StandardArticleCard(
                  article: article,
                  onTap: () {
                    _openArticleDetail(article);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
