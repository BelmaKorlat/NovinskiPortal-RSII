import 'package:flutter/foundation.dart';
import 'package:novinskiportal_mobile/models/auth_models.dart';
import 'package:novinskiportal_mobile/models/user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> login(LoginRequest req) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _service.login(req);
      _token = res.token;
      _user = res.user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', _token!);
    } on ApiException {
      _token = null;
      _user = null;

      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(RegisterRequest request) async {
    _loading = true;
    notifyListeners();

    try {
      await _service.register(request);
    } on ApiException {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    notifyListeners();
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      return await _service.isUsernameTaken(username);
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEmailTaken(String email) async {
    try {
      return await _service.isEmailTaken(email);
    } catch (_) {
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    await _service.forgotPassword(email);
  }
}
