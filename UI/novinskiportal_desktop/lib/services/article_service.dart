import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/article_models.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class ArticleService {
  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/Articles';

  ApiException _asApi(
    DioException e, {
    String fallback = 'Došlo je do greške.',
  }) {
    if (e.error is ApiException) return e.error as ApiException;

    final code = e.response?.statusCode;
    final data = e.response?.data;
    return ApiException(
      statusCode: code,
      message: humanMessage(code, data, fallback),
    );
  }

  Future<PagedResult<ArticleDto>> getPage(ArticleSearch s) async {
    try {
      final res = await _dio.get(_base, queryParameters: s.toQuery());

      final data = res.data;
      final list = readItems(data);
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(ArticleDto.fromJson)
          .toList();
      final total = readTotalCount(data) ?? items.length;
      return PagedResult(items: items, totalCount: total);
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješan GET.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<List<ArticleDto>> getList(ArticleSearch s) async {
    try {
      final res = await _dio.get(_base, queryParameters: s.toQuery());
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
      throw _asApi(e, fallback: 'Neuspješan GET članaka.');
    }
  }

  Future<ArticleDetailDto> getById(int id) async {
    try {
      final res = await _dio.get('$_base/$id/detail');
      if (res.data is Map<String, dynamic>) {
        return ArticleDetailDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješan GET by id.');
    }
  }

  Future<void> create(CreateArticleRequest r) async {
    try {
      await _dio.post(
        _base,
        data: r.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška prilikom kreiranja članka.');
    }
  }

  Future<void> update(int id, UpdateArticleRequest r) async {
    try {
      await _dio.put(
        '$_base/$id',
        data: r.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška prilikom ažuriranja članka.');
    }
  }

  // Future<void> update(int id, UpdateArticleRequest r) async {
  //   try {
  //     final res = await _dio.put('$_base/$id', data: r.toJson());
  //     final _ = res;
  //   } on DioException catch (e) {
  //     throw _asApi(
  //       e,
  //       fallback: 'Došlo je do greške prilikom ažuriranja članka.',
  //     );
  //   }
  // }

  Future<ArticleDto> toggleStatus(int id) async {
    try {
      final res = await _dio.patch('$_base/$id/status');
      if (res.data is Map<String, dynamic>) {
        return ArticleDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri ažuriranju statusa.');
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('$_base/$id');
      return true;
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri brisanju članka.');
    }
  }
}
