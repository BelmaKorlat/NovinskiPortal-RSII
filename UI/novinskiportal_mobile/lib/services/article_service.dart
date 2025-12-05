import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/category/category_articles_models.dart';
import 'package:novinskiportal_mobile/services/base_service.dart';
import '../models/article/article_models.dart';
import '../models/common/paging.dart';
import '../core/api_error.dart';

class ArticleService extends BaseService {
  static const String _base = '/api/Articles';

  Future<PagedResult<ArticleDto>> getPage(ArticleSearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      final data = res.data;
      final list = readItems(data);
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(ArticleDto.fromJson)
          .toList();
      final total = readTotalCount(data) ?? items.length;
      return PagedResult(items: items, totalCount: total);
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<List<ArticleDto>> getList(ArticleSearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());
      final data = res.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ArticleDto.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final list =
            data['items'] ?? data['data'] ?? data['result'] ?? data['records'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(ArticleDto.fromJson)
              .toList();
        }
        if (data.isEmpty) return <ArticleDto>[];
      }

      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET članaka.');
    }
  }

  Future<ArticleDetailDto> getById(int id) async {
    try {
      final res = await dio.get('$_base/$id/detail');
      if (res.data is Map<String, dynamic>) {
        return ArticleDetailDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET by id.');
    }
  }

  Future<List<CategoryArticlesDto>> getCategoryArticles({
    int perCategory = 5,
  }) async {
    try {
      final res = await dio.get(
        '$_base/category-articles',
        queryParameters: {'perCategory': perCategory},
      );

      final data = res.data as List<dynamic>;
      return data
          .map((e) => CategoryArticlesDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješno dobavljanje članaka.');
    }
  }

  Future<void> trackView(int id) async {
    try {
      await dio.post('$_base/$id/track-view');
    } on DioException catch (_) {}
  }

  Future<List<ArticleDto>> getPersonalized({int take = 6}) async {
    try {
      final res = await dio.get(
        '/api/recommendation/personalized',
        queryParameters: {'take': take},
      );

      final data = res.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ArticleDto.fromJson)
            .toList();
      }

      throw ApiException(message: 'Neočekivan oblik odgovora (preporuke).');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return <ArticleDto>[];
      }
      throw asApi(e, fallback: 'Neuspješno dobavljanje preporuka.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora (preporuke).');
    }
  }
}
