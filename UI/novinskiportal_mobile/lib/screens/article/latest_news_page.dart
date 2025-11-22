import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/providers/article/latest_articles_provider.dart';
import 'package:novinskiportal_mobile/widgets/common/app_main_app_bar.dart';
import 'package:novinskiportal_mobile/widgets/common/top_tabs.dart';
import 'package:novinskiportal_mobile/widgets/navigation/hamburger_menu.dart';
import 'package:novinskiportal_mobile/widgets/navigation/main_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/widgets/article/standard_article_card.dart';

class LatestNewsScreen extends StatefulWidget {
  const LatestNewsScreen({super.key});

  @override
  State<LatestNewsScreen> createState() => _LatestNewsScreenState();
}

class _LatestNewsScreenState extends State<LatestNewsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _topTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<LatestArticlesProvider>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<LatestArticlesProvider>();

    // odredi body prema stanju providera
    Widget body;

    if (provider.isLoading && provider.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.error != null && provider.items.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            provider.error!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: provider.loadInitial,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            TopTabs(
              currentIndex: _topTabIndex,
              labels: const ['Najnovije', 'Najčitanije', 'Uživo'],
              onChanged: (i) {
                setState(() {
                  _topTabIndex = i;
                });
                // ovdje kasnije dodaš logiku za Najčitanije / Uživo
              },
            ),
            const SizedBox(height: 8),
            for (final article in provider.items)
              StandardArticleCard(article: article),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,

      // isti app bar kao na početnoj, samo title drugačiji
      appBar: MainAppBar(
        title: 'Najnovije',
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onSearchTap: () {
          // kasnije: otvori search screen
        },
      ),

      drawer: const AppDrawer(),

      body: body,

      // zajednički bottom nav
      bottomNavigationBar: MainBottomNav(
        currentIndex: 0, // Početna je i dalje aktivan tab
        onTap: (index) {
          if (index == 0) {
            // klik na "Početna" sa ekrana Najnovije -> vrati se na Home
            Navigator.of(context).pop();
            return;
          }

          // ostale tabove (Favoriti, Dojava, Profil) rješavaš kasnije
        },
      ),
    );
  }
}
