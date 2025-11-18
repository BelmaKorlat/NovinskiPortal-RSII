import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/auth_models.dart';
import '../core/api_error.dart';

class AuthService {
  static const String loginPath = '/api/auth/login';
  static const String registerPath = '/api/auth/register';
  static const String checkUsernamePath = '/api/auth/check-username';
  static const String checkEmailPath = '/api/auth/check-email';

  final Dio _dio = ApiClient().dio;

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

  Future<AuthResponseDto> login(LoginRequest request) async {
    try {
      final res = await _dio.post(loginPath, data: request.toJson());

      if (res.data is Map<String, dynamic>) {
        return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan odgovor servera.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Pogrešan email/username ili lozinka.');
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      await _dio.post(registerPath, data: request.toJson());
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješna registracija.');
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      final res = await _dio.get(
        checkUsernamePath,
        queryParameters: {'username': username},
      );

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return data['taken'] == true;
      }
      return false;
    } on DioException {
      return false;
    }
  }

  Future<bool> isEmailTaken(String email) async {
    try {
      final res = await _dio.get(
        checkEmailPath,
        queryParameters: {'email': email},
      );

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return data['taken'] == true;
      }
      return false;
    } on DioException {
      return false;
    }
  }
}
