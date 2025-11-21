import 'package:flutter/material.dart';

class AppAssets {
  static String logoForTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? 'assets/images/novinskiportal_logo_white_shaded.png'
        : 'assets/images/novinskiportal_logo_transparent.png';
  }
}
