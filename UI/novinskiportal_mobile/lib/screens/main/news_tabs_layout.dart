import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/widgets/common/top_tabs.dart';
import 'package:novinskiportal_mobile/widgets/navigation/hamburger_menu.dart';

class NewsTabsLayout extends StatelessWidget {
  final String title;
  final int currentTopIndex;
  final List<String> topLabels;
  final ValueChanged<int> onTopChanged;
  final Widget child;

  const NewsTabsLayout({
    super.key,
    required this.title,
    required this.currentTopIndex,
    required this.topLabels,
    required this.onTopChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // ovdje kasnije otvoriš search screen
            },
          ),
        ],
      ),

      drawer: const AppDrawer(),

      body: SafeArea(
        child: Column(
          children: [
            TopTabs(
              currentIndex: currentTopIndex,
              labels: topLabels,
              onChanged: onTopChanged,
            ),
            const SizedBox(height: 8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
