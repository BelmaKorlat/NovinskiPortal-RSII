// lib/widgets/pagination_bar.dart
import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  /// 0-based index trenutne stranice
  final int page;

  /// Ukupan broj zapisa (ne stranica!)
  final int totalCount;

  /// Koliko zapisa po stranici
  final int pageSize;

  /// Callback za promjenu stranice (0-based)
  final ValueChanged<int> onPageChanged;

  /// Callback za promjenu page size-a
  final ValueChanged<int> onPageSizeChanged;

  /// Opcije za page size
  final List<int> pageSizeOptions;

  /// Koliko "susjednih" stranica prikazati oko aktivne (1 = ... 4 [5] 6 ...)
  final int window;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalCount,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [10, 20, 50],
    this.window = 1,
  });

  int get _lastPage => (totalCount == 0) ? 0 : ((totalCount - 1) ~/ pageSize);
  int get _pagesCount => _lastPage + 1;

  List<int?> _pagesToShow() {
    // int = index stranice; null = "…"
    if (_pagesCount <= 7) {
      return List<int>.generate(_pagesCount, (i) => i);
    }

    final set = <int>{
      0, _lastPage, // prva i zadnja
      1, if (_lastPage >= 1) _lastPage - 1, // druge po redu
      page, // aktivna
      ...List.generate(window, (i) => page - (i + 1)),
      ...List.generate(window, (i) => page + (i + 1)),
    }.where((i) => i >= 0 && i <= _lastPage).toList()..sort();

    final out = <int?>[];
    for (int i = 0; i < set.length; i++) {
      out.add(set[i]);
      if (i < set.length - 1 && (set[i + 1] - set[i]) > 1) {
        out.add(null); // rupa -> ubaci elipsu
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            // PREV
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Prethodna',
            ),

            // NUMERIČKE STRANICE
            ..._pagesToShow().map((idx) {
              if (idx == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('…'),
                );
              }
              final isCurrent = idx == page;
              return isCurrent
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () => onPageChanged(idx),
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(36, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text('${idx + 1}'),
                    );
            }),

            // NEXT
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: page < _lastPage
                  ? () => onPageChanged(page + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Sljedeća',
            ),

            // RAZMAK
            const SizedBox(width: 12),

            // PAGE SIZE
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Prikaži'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  child: DropdownButtonFormField<int>(
                    initialValue: pageSize,
                    isDense: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    items: pageSizeOptions
                        .map(
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null && v != pageSize) {
                        onPageSizeChanged(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
