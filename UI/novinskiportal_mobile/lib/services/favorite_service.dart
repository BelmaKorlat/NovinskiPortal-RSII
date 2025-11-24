import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/core/api_client.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/models/favorite/favorite_models.dart';

class FavoriteService {
  FavoriteService();

  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/Favorites';

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

  Future<List<FavoriteDto>> get() async {
    try {
      final res = await _dio.get(_base);
      final data = res.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(FavoriteDto.fromJson)
            .toList();
      }

      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješan GET spremljenih članaka.');
    }
  }

  Future<bool> create(int articleId) async {
    try {
      await _dio.post('$_base/$articleId');
      return true;
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješno spremanje članka.');
    }
  }

  Future<bool> remove(int articleId) async {
    try {
      final res = await _dio.delete('$_base/$articleId');

      if (res.statusCode == 204 || res.statusCode == 200) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw _asApi(e, fallback: 'Neuspješno uklanjanje članka.');
    }
  }

  Future<bool> isFavorite(int articleId) async {
    try {
      final res = await _dio.get('$_base/$articleId/is-favorite');
      final data = res.data;
      if (data is bool) return data;
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješna provjera spremljenog članka.');
    }
  }
}
