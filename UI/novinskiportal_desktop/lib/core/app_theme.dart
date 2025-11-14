import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      // Label i hint
      labelStyle: TextStyle(
        fontSize: 13,
        color: base.colorScheme.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: base.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
      ),

      // Borderi
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: base.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: base.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
      ),
    ),

    // Manji default font u formama (po želji)
    textTheme: base.textTheme.copyWith(
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 15),
    ),
    // Uniformni izgled dugmadi
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
        visualDensity: VisualDensity.compact,
        iconSize: 18,
      ),
    ),

    // Tabela (naslovi, visina redova, razmak kolona…)
    dataTableTheme: const DataTableThemeData(
      headingRowHeight: 44,
      dataRowMinHeight: 44,
      dataRowMaxHeight: 48,
      columnSpacing: 24,
      dividerThickness: 0.7,
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
  );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: base.colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      labelStyle: TextStyle(
        fontSize: 13,
        color: base.colorScheme.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: base.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: base.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: base.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
      ),
    ),

    textTheme: base.textTheme.copyWith(
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 15),
    ),
    // Uniformni izgled dugmadi
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
        visualDensity: VisualDensity.compact,
        iconSize: 18,
      ),
    ),

    // Tabela (naslovi, visina redova, razmak kolona…)
    dataTableTheme: const DataTableThemeData(
      headingRowHeight: 44,
      dataRowMinHeight: 44,
      dataRowMaxHeight: 48,
      columnSpacing: 24,
      dividerThickness: 0.7,
    ),
  );
}
