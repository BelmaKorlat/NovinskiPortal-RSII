import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/auth_models.dart';
import '../core/api_error.dart';

class AuthService {
  static const String loginPath = '/api/auth/login';

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

  Future<AuthResponseDto> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final req = LoginRequest(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      final res = await _dio.post(loginPath, data: req.toJson());

      if (res.data is Map<String, dynamic>) {
        return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan odgovor servera.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Pogrešan email ili lozinka.');
    }
  }
}
