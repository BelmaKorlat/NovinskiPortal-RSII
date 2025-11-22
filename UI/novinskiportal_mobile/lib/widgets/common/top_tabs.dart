import 'package:flutter/material.dart';

class TopTabs extends StatelessWidget {
  final int currentIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const TopTabs({
    super.key,
    required this.currentIndex,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final baseStyle =
        theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14);

    double measureTextWidth(String text) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: baseStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.size.width;
    }

    Widget buildTab(String label, int index) {
      final selected = currentIndex == index;
      final width = measureTextWidth(label);

      return GestureDetector(
        onTap: () => onChanged(index),
        child: Padding(
          padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 3,
                width: width,
                color: selected ? cs.onSurface : Colors.transparent,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: baseStyle.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: SizedBox(
        height: 36,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(height: 2, color: cs.outlineVariant),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < labels.length; i++)
                    buildTab(labels[i], i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
