import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryCoffee = Color(0xFF945230);
  static const Color secondaryCoffee = Color(0xFFF5E6D6);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static ThemeData light() {
    final base = ThemeData.light();

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryCoffee,
        secondary: primaryCoffee,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1F140F),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF8F1),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF8F1),
        foregroundColor: Color(0xFF1F140F),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFFFFF8F1),
        surfaceTintColor: Colors.transparent,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryCoffee,
        textColor: Color(0xFF1F140F),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCoffee, width: 1.4),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCoffee,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryCoffee,
        secondary: primaryCoffee,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryCoffee,
        textColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white54),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCoffee, width: 1.4),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCoffee,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      popupMenuTheme: const PopupMenuThemeData(
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
