import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final bool value;
  final String trueText;
  final String falseText;
  final IconData trueIcon;
  final IconData falseIcon;
  final EdgeInsets padding;
  final double iconSize;

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
      label: text,
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
