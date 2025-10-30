import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_error.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  static const String baseUrl =
      'https://localhost:7060'; // po potrebi promijeni

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );

    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            return host == 'localhost' || host == '127.0.0.1';
          };
      return client;
    };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final p = await SharedPreferences.getInstance();
          final token = p.getString('jwt');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (err, handler) {
          String message;
          int? status;
          final req = err.requestOptions;

          // mreža
          if (err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.sendTimeout ||
              err.type == DioExceptionType.receiveTimeout) {
            message = 'Veza je istekla. Pokušajte ponovo.';
          } else if (err.type == DioExceptionType.connectionError ||
              err.error is SocketException) {
            message = 'Nema veze sa serverom. Provjerite internet.';
          } else {
            // HTTP
            final resp = err.response;
            status = resp?.statusCode;
            final data = resp?.data;
            final path = req.path;
            final isLogin =
                path.endsWith('/api/auth/login') ||
                path.contains('/auth/login');

            if (status == 401 && isLogin) {
              message = 'Pogrešan username ili lozinka.';
            } else if ((status == 400 || status == 401) && isLogin) {
              message = 'Pogrešan username ili lozinka.';
            } else {
              message = humanMessage(status, data, 'Došlo je do greške.');
            }
          }

          handler.reject(
            DioException(
              requestOptions: req,
              error: ApiException(statusCode: status, message: message),
            ),
          );
        },
      ),
    );
  }
}
