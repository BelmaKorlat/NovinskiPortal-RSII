import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_error.dart';

abstract class BaseService {
  BaseService();

  final Dio dio = ApiClient().dio;

  ApiException asApi(
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
}
