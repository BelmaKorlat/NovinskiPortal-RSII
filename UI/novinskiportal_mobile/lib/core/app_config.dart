import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: kDebugMode ? 'http://10.0.2.2:5182' : 'http://10.0.2.2:5182',
    defaultValue: kDebugMode
        ? 'http://192.168.0.27:5182'
        : 'http://192.168.0.27:5182',
  );
}
