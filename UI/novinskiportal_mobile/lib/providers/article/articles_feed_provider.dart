import 'package:novinskiportal_mobile/models/common/paging.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/providers/page/paged_provider.dart';
import 'package:novinskiportal_mobile/services/article_service.dart';

class ArticlesFeedProvider extends PagedProvider<ArticleDto, ArticleSearch> {
  final ArticleService _service;
  final int? categoryId;
  final int? subcategoryId;

  ArticlesFeedProvider({
    this.categoryId,
    this.subcategoryId,
    ArticleService? service,
  }) : assert(categoryId != null || subcategoryId != null),
       _service = service ?? ArticleService();

  @override
  Future<PagedResult<ArticleDto>> fetch(ArticleSearch search) {
    return _service.getPage(search);
  }

  @override
  ArticleSearch buildSearch() {
    return ArticleSearch(
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      page: page,
      pageSize: pageSize,
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
