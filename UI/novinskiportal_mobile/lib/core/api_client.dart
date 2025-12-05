import 'dart:io';
import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/core/app_config.dart';
import 'package:novinskiportal_mobile/core/token_storage.dart';
import 'api_error.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  //static const String baseUrl = 'https://localhost:7060';
  //static const String baseUrl = 'https://10.0.2.2:7060';
  // Ako koristiš fizički telefon na istoj WiFi mreži, onda umjesto 10.0.2.2 stavi IP svog računara,
  //static const String baseUrl = 'http://192.168.0.27:5182';
  // static const String baseUrl = 'http://192.168.128.1:5182';

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.loadToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (err, handler) {
          String message;
          int? status;
          String? code;
          final req = err.requestOptions;

          if (err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.sendTimeout ||
              err.type == DioExceptionType.receiveTimeout) {
            message = 'Veza je istekla. Pokušajte ponovo.';
          } else if (err.type == DioExceptionType.connectionError ||
              err.error is SocketException) {
            message = 'Nema veze sa serverom. Provjerite internet.';
          } else {
            final resp = err.response;
            status = resp?.statusCode;
            final data = resp?.data;
            final path = req.path;
            final isLogin =
                path.endsWith('/api/auth/login') ||
                path.contains('/auth/login');

            final hadAuthHeader = req.headers['Authorization'] != null;

            if (data is Map && data['code'] is String) {
              code = data['code'] as String;
            }

            if (status == 401 && isLogin) {
              message = 'Pogrešan username ili lozinka.';
            } else if (status == 401 && !hadAuthHeader) {
              message = 'Za ovu akciju je potrebna prijava.';
            } else {
              message = humanMessage(status, data, 'Došlo je do greške.');
            }
          }

          handler.reject(
            DioException(
              requestOptions: req,
              error: ApiException(
                statusCode: status,
                message: message,
                code: code,
              ),
            ),
          );
        },
      ),
    );
  }
  static String resolveUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = AppConfig.apiBaseUrl;
    if (path.startsWith('/')) {
      return '$base$path';
    }
    return '$base/$path';
  }
}
