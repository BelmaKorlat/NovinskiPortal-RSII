// lib/core/utils/color_utils.dart
import 'package:flutter/material.dart';

Color? tryParseHexColor(String hex) {
  if (hex.isEmpty) return null; // ako je prazan, nema boje
  final h = hex.replaceAll('#', '').toUpperCase(); // skini #, normalizuj
  if (h.length != 6 && h.length != 8) return null;
  final withAlpha = h.length == 6 ? 'FF$h' : h; // dodaj punu neprozirnost
  try {
    return Color(
      int.parse(withAlpha, radix: 16),
    ); // parsiraj hex u int, napravi Color
  } catch (_) {
    return null; // ako padne parse, vrati null
  }
}

// #RRGGBB u uvijek velikim slovima
String colorToHex6(Color c) {
  final v = c.value & 0x00FFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
