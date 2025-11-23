import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/screens/article/home_page.dart';
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
  late final List<Widget> _pages;
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Novinski portal',
    'Favoriti',
    'Dojava vijesti',
    'Profil',
  ];
  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(key: _homeKey),
      const _FavoritesTab(),
      const _ReportNewsTab(),
      const _ProfileTab(),
    ];
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
        onSearchTap: () {
          // ovdje kasnije ide navigacija na search ekran
        },
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Favoriti'));
  }
}

class _ReportNewsTab extends StatelessWidget {
  const _ReportNewsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dojava vijesti'));
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profil'));
  }
}
