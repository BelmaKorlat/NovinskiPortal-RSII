import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/category/category_menu_models.dart';
import '../core/api_client.dart';
import '../core/api_error.dart';

class CategoryService {
  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/Categories';

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

  Future<List<CategoryMenuDto>> getMenu() async {
    try {
      final res = await _dio.get('$_base/categories-menu');
      final data = res.data as List<dynamic>;

      return data
          .map((e) => CategoryMenuDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri učitavanju kategorija.');
    }
  }
}
