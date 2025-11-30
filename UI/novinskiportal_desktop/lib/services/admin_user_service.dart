import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../models/admin_user_models.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class AdminUserService extends BaseService {
  static const String _base = '/api/Admin/Users';
  static const String _checkUsernamePath = '/api/Auth/check-username';
  static const String _checkEmailPath = '/api/Auth/check-email';

  Future<PagedResult<UserAdminDto>> getPage(UserAdminSearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapPagedResponse<UserAdminDto>(
        res.data,
        (m) => UserAdminDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<List<UserAdminDto>> getList(UserAdminSearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapListResponse<UserAdminDto>(
        res.data,
        (m) => UserAdminDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET korisnika.');
    }
  }

  Future<UserAdminDto> getById(int id) async {
    try {
      final res = await dio.get('$_base/$id');
      if (res.data is Map<String, dynamic>) {
        return UserAdminDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET by id.');
    }
  }

  Future<void> create(CreateAdminUserRequest r) async {
    try {
      await dio.post(_base, data: r.toJson());
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = humanMessage(
        code,
        e.response?.data,
        'Došlo je do greške prilikom kreiranja korisnika.',
      );
      throw ApiException(statusCode: code, message: msg);
    }
  }

  Future<void> update(int id, UpdateAdminUserRequest r) async {
    try {
      await dio.put('$_base/$id', data: r.toJson());
    } on DioException catch (e) {
      throw asApi(
        e,
        fallback: 'Došlo je do greške prilikom ažuriranja korisnika.',
      );
    }
  }

  Future<void> changePasswordForUser(
    int id,
    AdminChangePasswordRequest r,
  ) async {
    try {
      await dio.post('$_base/$id/change-password', data: r.toJson());
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = humanMessage(
        code,
        e.response?.data,
        'Došlo je do greške prilikom reset lozinke.',
      );
      throw ApiException(statusCode: code, message: msg);
    }
  }

  Future<UserAdminDto> toggleStatus(int id) async {
    try {
      final res = await dio.patch('$_base/$id/status');
      if (res.data is Map<String, dynamic>) {
        return UserAdminDto.fromJson(res.data as Map<String, dynamic>);
      }
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri ažuriranju statusa.');
    }
  }

  Future<void> softDelete(int id) async {
    try {
      await dio.delete('$_base/$id/soft-delete');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri brisanju korisnika.');
    }
  }

  Future<UserAdminDto> changeRole(int id, int roleId) async {
    try {
      final res = await dio.patch(
        '$_base/$id/role',
        queryParameters: {'roleId': roleId},
      );

      if (res.data is Map<String, dynamic>) {
        return UserAdminDto.fromJson(res.data as Map<String, dynamic>);
      }

      throw ApiException(
        message: 'Neočekivan oblik odgovora pri promjeni uloge.',
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri promjeni uloge.');
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      final res = await dio.get(
        _checkUsernamePath,
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
        _checkEmailPath,
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
