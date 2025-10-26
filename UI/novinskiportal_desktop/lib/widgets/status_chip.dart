import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final bool value; // npr. aktivna ili ne
  final String trueText; // "DA"
  final String falseText; // "NE"
  final IconData trueIcon; // Icons.check
  final IconData falseIcon; // Icons.close
  final EdgeInsets padding; // po želji
  final double iconSize; // po želji

  const StatusChip({
    super.key,
    required this.value,
    this.trueText = 'DA',
    this.falseText = 'NE',
    this.trueIcon = Icons.check,
    this.falseIcon = Icons.close,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = value ? cs.primaryContainer : cs.errorContainer;
    final fg = value ? cs.onPrimaryContainer : cs.onErrorContainer;
    final icon = value ? trueIcon : falseIcon;
    final text = value ? trueText : falseText;

    return Semantics(
      label: text, // pristupačnost
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
