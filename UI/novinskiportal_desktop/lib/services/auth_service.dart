import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../models/auth_models.dart';
import '../core/api_error.dart';

class AuthService extends BaseService {
  static const String loginPath = '/api/auth/login';

  Future<AuthResponseDto> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final req = LoginRequest(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      final res = await dio.post(loginPath, data: req.toJson());

      if (res.data is Map<String, dynamic>) {
        return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan odgovor servera.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Pogrešan email ili lozinka.');
    }
  }
}
