import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/screens/article/home_page.dart';
import 'package:novinskiportal_mobile/screens/favorite/favorite_list_page.dart';
import 'package:novinskiportal_mobile/screens/news_report/news_report_page.dart';
import 'package:novinskiportal_mobile/widgets/common/app_main_app_bar.dart';
import 'package:novinskiportal_mobile/widgets/navigation/hamburger_menu.dart';
import 'package:novinskiportal_mobile/widgets/navigation/main_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<FavoriteListPageState> _favoritesKey =
      GlobalKey<FavoriteListPageState>();
  final GlobalKey<NewsReportPageState> _reportKey =
      GlobalKey<NewsReportPageState>();

  late final List<Widget> _pages;
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Novinski portal',
    'Spremljeni članci',
    'Dojava vijesti',
    'Profil',
  ];
  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(key: _homeKey),
      FavoriteListPage(key: _favoritesKey),
      NewsReportPage(key: _reportKey),
      const _ProfileTab(),
    ];
  }

  void _onFavoritesMore() {
    _favoritesKey.currentState?.enterSelectionMode();
  }

  void _onReportSubmit() {
    _reportKey.currentState?.submit();
  }

  void _resetReportIfLeaving(int newIndex) {
    if (_currentIndex == 2 && newIndex != 2) {
      _reportKey.currentState?.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: MainAppBar(
        title: _titles[_currentIndex],
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onSearchTap: _currentIndex == 2
            ? _onReportSubmit
            : (_currentIndex == 1 ? null : () {}),
        actionIcon: _currentIndex == 2 ? Icons.send : Icons.search,
        onMoreTap: _currentIndex == 1 ? _onFavoritesMore : null,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _resetReportIfLeaving(index);
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profil'));
  }
}
