// lib/services/category_service.dart
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/category_models.dart';

class CategoryService {
  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/Categories';

  Future<PagedResult<CategoryDto>> getPage(CategorySearch s) async {
    final res = await _dio.get(_base, queryParameters: s.toQuery());
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      final rawList = data['items'] ?? data['Items'];
      final list = rawList is List ? rawList : const [];
      final total = data['totalCount'] as int? ?? data['TotalCount'] as int?;
      final items = list
          .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return PagedResult(items: items, totalCount: total);
    }
    throw Exception('Neuspješan GET (${res.statusCode})');
  }

  //  lista
  Future<List<CategoryDto>> getList(CategorySearch s) async {
    final res = await _dio.get(_base, queryParameters: s.toQuery());

    if (res.statusCode == 200) {
      final data = res.data;

      // 1) /api/Categories → vrati čisti niz
      if (data is List) {
        return data
            .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // 2) /api/Categories → vrati objekat s paginacijom (items/data/result/records)
      if (data is Map<String, dynamic>) {
        final list =
            data['items'] ?? data['data'] ?? data['result'] ?? data['records'];

        if (list is List) {
          return list
              .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        // Ako backend vrati prazan objekat {}
        if (data.isEmpty) return <CategoryDto>[];
      }

      // Ako dođeš dovde – format je neočekivan
      throw Exception('Neočekivan oblik odgovora: ${data.runtimeType}');
    }

    throw Exception('Neuspješan GET kategorija (${res.statusCode})');
  }

  Future<CategoryDto> getById(int id) async {
    final res = await _dio.get('$_base/$id');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return CategoryDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Neuspješan GET by id (${res.statusCode})');
  }

  Future<CategoryDto> create(CreateCategoryRequest r) async {
    final res = await _dio.post(_base, data: r.toJson());
    if (res.statusCode == 200 || res.statusCode == 201) {
      return CategoryDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Neuspješan CREATE (${res.statusCode})');
  }

  Future<CategoryDto> update(int id, UpdateCategoryRequest r) async {
    final res = await _dio.put('$_base/$id', data: r.toJson());
    if (res.statusCode == 200 || res.statusCode == 204) {
      return CategoryDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Neuspješan UPDATE (${res.statusCode})');
  }

  Future<CategoryDto> toggleStatus(int id) async {
    final res = await _dio.patch('$_base/$id/status');
    if (res.statusCode == 200) {
      return CategoryDto.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Neuspješan TOGGLE (${res.statusCode})');
  }

  Future<bool> delete(int id) async {
    final res = await _dio.delete('$_base/$id');
    if (res.statusCode == 200 || res.statusCode == 204) return true;
    throw Exception('Neuspješan DELETE (${res.statusCode})');
  }
}
