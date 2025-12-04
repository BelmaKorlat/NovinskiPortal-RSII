import '../../models/article/article_models.dart';
import '../../services/article_service.dart';
import '../page/paged_provider.dart';
import '../../models/common/paging.dart';

class ArticleProvider extends PagedProvider<ArticleDto, ArticleSearch> {
  final _service = ArticleService();

  int? categoryId;
  int? subcategoryId;
  int? userId;
  String fts = '';

  @override
  ArticleSearch buildSearch() => ArticleSearch(
    fts: fts.trim().isEmpty ? null : fts.trim(),
    categoryId: categoryId,
    subcategoryId: subcategoryId,
    userId: userId,
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
  );

  @override
  Future<PagedResult<ArticleDto>> fetch(ArticleSearch s) {
    return _service.getPage(s);
  }

  // Future<ArticleDetailDto> getDetail(int id) async {
  //   return await _service.getById(id);
  // }
  Future<ArticleDetailDto> getDetail(int id) async {
    try {
      // prvo pošaljemo track view
      await _service.trackView(id);
    } catch (_) {
      // ako pukne statistika, ignoriramo
      // korisnik i dalje treba da vidi članak
    }

    // onda učitamo detalje
    return await _service.getById(id);
  }
}
