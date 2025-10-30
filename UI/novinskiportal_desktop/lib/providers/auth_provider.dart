import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
}
