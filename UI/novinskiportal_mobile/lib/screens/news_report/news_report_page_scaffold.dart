import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/providers/news_report/news_report_provider.dart';
import 'package:novinskiportal_mobile/screens/news_report/news_report_page.dart';

class NewsReportPageScaffold extends StatefulWidget {
  const NewsReportPageScaffold({super.key});

  @override
  State<NewsReportPageScaffold> createState() => _NewsReportPageScaffoldState();
}

class _NewsReportPageScaffoldState extends State<NewsReportPageScaffold> {
  final GlobalKey<NewsReportPageState> _reportKey =
      GlobalKey<NewsReportPageState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final reportProvider = context.watch<NewsReportProvider>();
    final isSubmitting = reportProvider.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Dojava vijesti',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: isSubmitting
                ? null
                : () {
                    _reportKey.currentState?.submit();
                  },
            tooltip: 'Pošalji dojavu',
          ),
        ],
      ),
      body: SafeArea(child: NewsReportPage(key: _reportKey)),
    );
  }
}
