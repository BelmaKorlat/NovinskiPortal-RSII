import 'package:flutter/foundation.dart';
import 'package:novinskiportal_desktop/core/token_storage.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../core/api_error.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  String? _token;
  UserDto? _user;
  bool _loading = false;

  String? get token => _token;
  UserDto? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _token != null;

  int? get userId => _user?.id;
  String get fullName =>
      _user == null ? '' : '${_user!.firstName} ${_user!.lastName}'.trim();

  Future<void> login(String emailOrUsername, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _service.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );
      _token = res.token;
      _user = res.user;

      await TokenStorage.saveToken(_token!);
    } on ApiException {
      _token = null;
      _user = null;
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadToken() async {
    _token = await TokenStorage.loadToken();

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await TokenStorage.clearToken();
    notifyListeners();
  }
}
