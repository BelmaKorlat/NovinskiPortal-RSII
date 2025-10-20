import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String loginPath = '/api/auth/login'; // uskladi sa backend rutom

  final Dio _dio = ApiClient().dio;

  Future<AuthResponseDto> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final res = await _dio.post(
      loginPath,
      data: {'emailOrUsername': emailOrUsername, 'password': password},
    );

    if (res.statusCode == 200 && res.data is Map) {
      return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
    }

    if (res.statusCode == 400 || res.statusCode == 401) {
      throw Exception('Pogrešan email ili lozinka');
    }

    throw Exception('Greška servera ${res.statusCode}');
  }
}
