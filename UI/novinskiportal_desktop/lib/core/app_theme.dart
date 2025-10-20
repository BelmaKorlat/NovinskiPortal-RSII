import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}
