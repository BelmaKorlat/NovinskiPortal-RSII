// lib/core/api_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // OVO je bitno

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
        validateStatus: (s) => s != null && s >= 200 && s < 500,
      ),
    );

    // Dev: dozvoli self-signed cert za localhost
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
          // Token će dodati provider kad ga sačuva u SharedPreferences
          // Ako želiš odmah, dodaj čitanje SharedPreferences ovdje.
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (err, handler) => handler.next(err),
      ),
    );
  }
}
