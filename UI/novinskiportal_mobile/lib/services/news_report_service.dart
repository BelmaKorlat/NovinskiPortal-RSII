import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/news_report/news_report_models.dart';

import '../core/api_client.dart';
import '../core/api_error.dart';

class NewsReportService {
  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/NewsReport';

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

  Future<void> create(CreateNewsReportRequest r) async {
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
      throw _asApi(e, fallback: 'Greška prilikom slanja dojave.');
    }
  }
}
