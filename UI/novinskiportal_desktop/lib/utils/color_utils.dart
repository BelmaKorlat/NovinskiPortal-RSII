import 'package:flutter/material.dart';

Color? tryParseHexColor(String hex) {
  if (hex.isEmpty) return null;
  final h = hex.replaceAll('#', '').toUpperCase();
  if (h.length != 6 && h.length != 8) return null;
  final withAlpha = h.length == 6 ? 'FF$h' : h;
  try {
    return Color(int.parse(withAlpha, radix: 16));
  } catch (_) {
    return null;
  }
}

String colorToHex6(Color c) {
  final v = c.value & 0x00FFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
