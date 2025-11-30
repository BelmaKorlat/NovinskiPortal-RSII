import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../models/article_models.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class ArticleService extends BaseService {
  static const String _base = '/api/Articles';

  Future<PagedResult<ArticleDto>> getPage(ArticleSearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapPagedResponse<ArticleDto>(
        res.data,
        (m) => ArticleDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<List<ArticleDto>> getList(ArticleSearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapListResponse<ArticleDto>(
        res.data,
        (m) => ArticleDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET članaka.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
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

  Future<void> create(CreateArticleRequest r) async {
    try {
      await dio.post(
        _base,
        data: r.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška prilikom kreiranja članka.');
    }
  }

  Future<void> update(int id, UpdateArticleRequest r) async {
    try {
      await dio.put(
        '$_base/$id',
        data: r.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška prilikom ažuriranja članka.');
    }
  }

  Future<ArticleDto> toggleStatus(int id) async {
    try {
      final res = await dio.patch('$_base/$id/status');
      if (res.data is Map<String, dynamic>) {
        return ArticleDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri ažuriranju statusa.');
    }
  }

  Future<void> delete(int id) async {
    try {
      await dio.delete('$_base/$id');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri brisanju članka.');
    }
  }
}
