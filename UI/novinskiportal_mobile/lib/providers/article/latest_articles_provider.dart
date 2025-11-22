import 'package:novinskiportal_mobile/models/common/paging.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/providers/page/paged_provider.dart';
import 'package:novinskiportal_mobile/services/article_service.dart';

class LatestArticlesProvider extends PagedProvider<ArticleDto, ArticleSearch> {
  final ArticleService _service;

  LatestArticlesProvider({ArticleService? service})
    : _service = service ?? ArticleService();

  @override
  Future<PagedResult<ArticleDto>> fetch(ArticleSearch search) {
    return _service.getPage(search);
  }

  @override
  ArticleSearch buildSearch() {
    return ArticleSearch(
      page: page,
      pageSize: pageSize,
      // kasnije možeš dodati sortBy / sortDirection ako treba
    );
  }

  bool get hasMore => items.length < totalCount;

  Future<void> loadInitial() async {
    page = 0;
    await load();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    page += 1;
    await load(append: true);
  }
}
