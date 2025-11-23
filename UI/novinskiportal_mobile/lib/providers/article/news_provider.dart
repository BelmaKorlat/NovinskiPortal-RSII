import 'package:novinskiportal_mobile/models/article/news_mode.dart';
import 'package:novinskiportal_mobile/models/common/paging.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/providers/page/paged_provider.dart';
import 'package:novinskiportal_mobile/services/article_service.dart';

class NewsProvider extends PagedProvider<ArticleDto, ArticleSearch> {
  final ArticleService _service;

  NewsMode _mode = NewsMode.latest;
  NewsMode get mode => _mode;

  NewsProvider({ArticleService? service})
    : _service = service ?? ArticleService();

  @override
  Future<PagedResult<ArticleDto>> fetch(ArticleSearch search) {
    return _service.getPage(search);
  }

  @override
  ArticleSearch buildSearch() {
    String modeString;
    switch (_mode) {
      case NewsMode.latest:
        modeString = 'latest';
        break;
      case NewsMode.mostread:
        modeString = 'mostread';
        break;
      case NewsMode.live:
        modeString = 'live';
        break;
    }

    return ArticleSearch(page: page, pageSize: pageSize, mode: modeString);
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

  Future<void> changeMode(NewsMode newMode) async {
    if (_mode == newMode) return;

    _mode = newMode;
    page = 0;
    await load();
  }
}
