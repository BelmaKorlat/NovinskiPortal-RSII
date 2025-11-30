import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../models/subcategory_models.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class SubcategoryService extends BaseService {
  static const String _base = '/api/Subcategories';

  Future<PagedResult<SubcategoryDto>> getPage(SubcategorySearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapPagedResponse<SubcategoryDto>(
        res.data,
        (m) => SubcategoryDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<List<SubcategoryDto>> getList(SubcategorySearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapListResponse<SubcategoryDto>(
        res.data,
        (m) => SubcategoryDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET potkategorija.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<SubcategoryDto> getById(int id) async {
    try {
      final res = await dio.get('$_base/$id');
      if (res.data is Map<String, dynamic>) {
        return SubcategoryDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET by id.');
    }
  }

  Future<void> create(CreateSubcategoryRequest r) async {
    try {
      await dio.post(_base, data: r.toJson());
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = humanMessage(
        code,
        e.response?.data,
        'Došlo je do greške prilikom kreiranja potkategorije.',
      );
      throw ApiException(statusCode: code, message: msg);
    }
  }

  Future<void> update(int id, UpdateSubcategoryRequest r) async {
    try {
      await dio.put('$_base/$id', data: r.toJson());
    } on DioException catch (e) {
      throw asApi(
        e,
        fallback: 'Došlo je do greške prilikom ažuriranja potkategorije.',
      );
    }
  }

  Future<SubcategoryDto> toggleStatus(int id) async {
    try {
      final res = await dio.patch('$_base/$id/status');
      if (res.data is Map<String, dynamic>) {
        return SubcategoryDto.fromJson(res.data as Map<String, dynamic>);
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
      throw asApi(e, fallback: 'Greška pri brisanju potkategorije.');
    }
  }
}
