import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/category/category_menu_models.dart';
import 'package:novinskiportal_mobile/services/base_service.dart';

class CategoryService extends BaseService {
  static const String _base = '/api/Categories';

  Future<List<CategoryMenuDto>> getMenu() async {
    try {
      final res = await dio.get('$_base/categories-menu');
      final data = res.data as List<dynamic>;

      return data
          .map((e) => CategoryMenuDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri učitavanju kategorija.');
    }
  }
}
