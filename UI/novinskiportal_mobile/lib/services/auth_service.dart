import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/services/base_service.dart';
import '../models/auth/auth_models.dart';
import '../core/api_error.dart';

class AuthService extends BaseService {
  static const String loginPath = '/api/auth/login';
  static const String registerPath = '/api/auth/register';
  static const String checkUsernamePath = '/api/auth/check-username';
  static const String checkEmailPath = '/api/auth/check-email';
  static const String forgotPasswordPath = '/api/auth/forgot-password';

  Future<AuthResponseDto> login(LoginRequest request) async {
    try {
      final res = await dio.post(loginPath, data: request.toJson());

      if (res.data is Map<String, dynamic>) {
        return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan odgovor servera.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Pogrešan email/username ili lozinka.');
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      await dio.post(registerPath, data: request.toJson());
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješna registracija.');
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      final res = await dio.get(
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
      final res = await dio.get(
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

  Future<void> forgotPassword(String email) async {
    try {
      await dio.post(forgotPasswordPath, data: {'email': email});
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan reset lozinke.');
    }
  }
}
