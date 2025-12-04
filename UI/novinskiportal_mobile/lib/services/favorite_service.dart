import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/models/favorite/favorite_models.dart';
import 'package:novinskiportal_mobile/services/base_service.dart';

class FavoriteService extends BaseService {
  FavoriteService();

  static const String _base = '/api/Favorites';

  Future<List<FavoriteDto>> get() async {
    try {
      final res = await dio.get(_base);
      final data = res.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(FavoriteDto.fromJson)
            .toList();
      }

      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException(
          statusCode: 401,
          message: 'Za pregled spremljenih članaka potrebna je prijava.',
        );
      }

      throw asApi(e, fallback: 'Neuspješan GET spremljenih članaka.');
    }
  }

  Future<bool> create(int articleId) async {
    try {
      await dio.post('$_base/$articleId');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException(
          statusCode: 401,
          message: 'Za spremanje članka u favorite potrebna je prijava.',
        );
      }

      throw asApi(e, fallback: 'Neuspješno spremanje članka.');
    }
  }

  Future<bool> remove(int articleId) async {
    try {
      final res = await dio.delete('$_base/$articleId');

      if (res.statusCode == 204 || res.statusCode == 200) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException(
          statusCode: 401,
          message: 'Za uklanjanje članka iz favorita potrebna je prijava.',
        );
      }

      if (e.response?.statusCode == 404) {
        return false;
      }

      throw asApi(e, fallback: 'Neuspješno uklanjanje članka.');
    }
  }

  Future<bool> isFavorite(int articleId) async {
    try {
      final res = await dio.get('$_base/$articleId/is-favorite');
      final data = res.data;
      if (data is bool) return data;
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException(
          statusCode: 401,
          message: 'Za provjeru favorita potrebna je prijava.',
        );
      }

      throw asApi(e, fallback: 'Neuspješna provjera spremljenog članka.');
    }
  }
}
