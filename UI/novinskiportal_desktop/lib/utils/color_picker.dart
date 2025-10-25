import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'color_utils.dart';

Future<String?> pickHexColor(BuildContext context, String currentHex) async {
  Color current = tryParseHexColor(currentHex) ?? Colors.blue;
  Color selected = current;

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Odaberi boju'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: current,
          onColorChanged: (c) => selected = c,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Odustani'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Potvrdi'),
        ),
      ],
    ),
  );

  if (ok == true) return colorToHex6(selected);
  return null;
}
