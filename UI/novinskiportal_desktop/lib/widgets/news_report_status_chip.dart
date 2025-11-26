import 'package:flutter/material.dart';
import '../models/news_report_models.dart';

class NewsReportStatusChip extends StatelessWidget {
  final NewsReportStatus status;

  const NewsReportStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    String text;

    switch (status) {
      case NewsReportStatus.pending:
        bg = cs.primary.withValues(alpha: 0.12);
        fg = cs.primary;
        text = 'Na čekanju';
        break;
      case NewsReportStatus.approved:
        bg = Colors.green.withValues(alpha: 0.12);
        fg = Colors.green.shade800;
        text = 'Prihvaćena';
        break;
      case NewsReportStatus.rejected:
        bg = Colors.red.withValues(alpha: 0.12);
        fg = Colors.red.shade800;
        text = 'Odbijena';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
