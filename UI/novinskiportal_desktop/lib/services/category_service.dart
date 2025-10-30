import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/category_models.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class CategoryService {
  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/Categories';

  // Pomoćni metod za konzistentno mapiranje DioException -> ApiException
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

  Future<PagedResult<CategoryDto>> getPage(CategorySearch s) async {
    try {
      final res = await _dio.get(_base, queryParameters: s.toQuery());

      final data = res.data;
      final list = readItems(data);
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(CategoryDto.fromJson)
          .toList();
      final total = readTotalCount(data) ?? items.length;
      return PagedResult(items: items, totalCount: total);
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješan GET.');
      //  throw _asApi(e, fallback: 'Greška prilikom dobavljanja kategorija.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<List<CategoryDto>> getList(CategorySearch s) async {
    try {
      final res = await _dio.get(_base, queryParameters: s.toQuery());
      final data = res.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(CategoryDto.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final list =
            data['items'] ?? data['data'] ?? data['result'] ?? data['records'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(CategoryDto.fromJson)
              .toList();
        }
        if (data.isEmpty) return <CategoryDto>[];
      }

      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješan GET kategorija.');
    }
  }

  Future<CategoryDto> getById(int id) async {
    try {
      final res = await _dio.get('$_base/$id');
      if (res.data is Map<String, dynamic>) {
        return CategoryDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješan GET by id.');
    }
  }

  Future<void> create(CreateCategoryRequest r) async {
    try {
      await _dio.post(_base, data: r.toJson());
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = humanMessage(
        code,
        e.response?.data,
        'Došlo je do greške prilikom kreiranja kategorije.',
      );
      throw ApiException(statusCode: code, message: msg);
    }
  }

  Future<void> update(int id, UpdateCategoryRequest r) async {
    try {
      final res = await _dio.put('$_base/$id', data: r.toJson());
      final _ = res;
    } on DioException catch (e) {
      throw _asApi(
        e,
        fallback: 'Došlo je do greške prilikom ažuriranja kategorije.',
      );
    }
  }

  Future<CategoryDto> toggleStatus(int id) async {
    try {
      final res = await _dio.patch('$_base/$id/status');
      if (res.data is Map<String, dynamic>) {
        return CategoryDto.fromJson(res.data as Map<String, dynamic>);
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
      throw _asApi(e, fallback: 'Greška pri brisanju kategorije.');
    }
  }
}
