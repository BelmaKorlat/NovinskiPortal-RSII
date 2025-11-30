import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../models/category_models.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class CategoryService extends BaseService {
  static const String _base = '/api/Categories';

  Future<PagedResult<CategoryDto>> getPage(CategorySearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapPagedResponse<CategoryDto>(
        res.data,
        (m) => CategoryDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<List<CategoryDto>> getList(CategorySearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapListResponse<CategoryDto>(
        res.data,
        (m) => CategoryDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET kategorija.');
    }
  }

  Future<CategoryDto> getById(int id) async {
    try {
      final res = await dio.get('$_base/$id');
      if (res.data is Map<String, dynamic>) {
        return CategoryDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET by id.');
    }
  }

  Future<void> create(CreateCategoryRequest r) async {
    try {
      await dio.post(_base, data: r.toJson());
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
      final res = await dio.put('$_base/$id', data: r.toJson());
      final _ = res;
    } on DioException catch (e) {
      throw asApi(
        e,
        fallback: 'Došlo je do greške prilikom ažuriranja kategorije.',
      );
    }
  }

  Future<CategoryDto> toggleStatus(int id) async {
    try {
      final res = await dio.patch('$_base/$id/status');
      if (res.data is Map<String, dynamic>) {
        return CategoryDto.fromJson(res.data as Map<String, dynamic>);
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
      throw asApi(e, fallback: 'Greška pri brisanju kategorije.');
    }
  }
}
