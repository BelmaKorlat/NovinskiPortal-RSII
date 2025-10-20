import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _k = 'themeMode'; // 'light', 'dark', 'system'
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_k);
    switch (v) {
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      case 'system':
        _mode = ThemeMode.system;
        break;
      default:
        _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> set(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    final s = m == ThemeMode.dark
        ? 'dark'
        : m == ThemeMode.system
        ? 'system'
        : 'light';
    await p.setString(_k, s);
  }

  Future<void> toggleLightDark() =>
      set(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
