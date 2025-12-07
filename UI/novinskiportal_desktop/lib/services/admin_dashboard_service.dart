import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/models/admin_dashboard_models.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../core/api_error.dart';

class AdminDashboardService extends BaseService {
  static const String _base = '/api/AdminDashboard';

  Future<DashboardSummary> getSummary() async {
    try {
      final res = await dio.get(_base);

      final data = res.data;

      if (data is Map<String, dynamic>) {
        return DashboardSummary.fromJson(data);
      }

      throw ApiException(message: 'Neočekivan oblik odgovora za dashboard.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri učitavanju dashboard podataka.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora za dashboard.');
    }
  }

  Future<List<DashboardTopArticle>> getTopArticles({
    int? categoryId,
    DateTime? from,
    DateTime? to,
    int take = 15,
  }) async {
    final queryParams = <String, dynamic>{'take': take.toString()};

    if (categoryId != null) {
      queryParams['categoryId'] = categoryId.toString();
    }

    if (from != null) {
      queryParams['from'] = from.toIso8601String();
    }

    if (to != null) {
      queryParams['to'] = to.toIso8601String();
    }

    final response = await dio.get(
      '$_base/top-articles',
      queryParameters: queryParams,
    );

    final data = response.data as List;

    return data
        .map((e) => DashboardTopArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Uint8List> downloadTopArticlesReport({
    int? categoryId,
    DateTime? from,
    DateTime? to,
    int take = 15,
  }) async {
    final queryParams = <String, dynamic>{'take': take.toString()};

    if (categoryId != null) {
      queryParams['categoryId'] = categoryId.toString();
    }

    if (from != null) {
      queryParams['from'] = from.toIso8601String();
    }

    if (to != null) {
      queryParams['to'] = to.toIso8601String();
    }

    try {
      final res = await dio.get<List<int>>(
        '$_base/top-articles-report',
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );

      final data = res.data;
      if (data == null) {
        throw ApiException(message: 'Prazan PDF odgovor sa servera.');
      }

      return Uint8List.fromList(data);
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri preuzimanju izvještaja.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora za izvještaj.');
    }
  }

  Future<Uint8List> downloadCategoryViewsReport() async {
    try {
      final res = await dio.get<List<int>>(
        '$_base/category-views-report',
        options: Options(responseType: ResponseType.bytes),
      );

      final data = res.data;
      if (data == null) {
        throw ApiException(message: 'Prazan PDF odgovor sa servera.');
      }

      return Uint8List.fromList(data);
    } on DioException catch (e) {
      throw asApi(
        e,
        fallback: 'Greška pri preuzimanju izvještaja po kategorijama.',
      );
    } catch (_) {
      throw ApiException(
        message: 'Neočekivan oblik odgovora za izvještaj po kategorijama.',
      );
    }
  }
}
