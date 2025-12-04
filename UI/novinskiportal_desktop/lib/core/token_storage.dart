import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _key = 'jwt';
  static String? _cache;

  static Future<void> saveToken(String token) async {
    _cache = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<String?> loadToken() async {
    if (_cache != null) return _cache;

    final prefs = await SharedPreferences.getInstance();
    _cache = prefs.getString(_key);
    return _cache;
  }

  static Future<void> clearToken() async {
    _cache = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
