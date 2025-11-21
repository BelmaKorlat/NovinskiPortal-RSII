import 'package:novinskiportal_mobile/core/notification_service.dart';

import '../models/article_models.dart';
import '../services/article_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

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

  Future<ArticleDetailDto> getDetail(int id) async {
    try {
      return await _service.getById(id);
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri učitavanju članka.');
      rethrow;
    }
  }
}
