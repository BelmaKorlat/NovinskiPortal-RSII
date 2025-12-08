import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/user/user_models.dart';
import 'package:novinskiportal_mobile/services/base_service.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';

class UserService extends BaseService {
  static const String _base = '/api/Users';

  Future<UserDto> getProfile() async {
    try {
      final res = await dio.get(_base);

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return UserDto.fromJson(data);
      }

      throw ApiException(message: 'Neočekivan oblik odgovora (profil).');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješno dobavljanje profila.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora (profil).');
    }
  }

  Future<UserDto> updateProfile(UpdateProfileRequest req) async {
    try {
      final res = await dio.put(_base, data: req.toJson());

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return UserDto.fromJson(data);
      }

      throw ApiException(
        message: 'Neočekivan oblik odgovora (update profila).',
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješna izmjena profila.');
    } catch (_) {
      throw ApiException(
        message: 'Neočekivan oblik odgovora (update profila).',
      );
    }
  }

  Future<void> changePassword(ChangePasswordRequest req) async {
    try {
      await dio.put('$_base/password', data: req.toJson());
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješna promjena lozinke.');
    }
  }
}
