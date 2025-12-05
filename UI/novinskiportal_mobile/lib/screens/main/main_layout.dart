import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/providers/auth/auth_provider.dart';
import 'package:novinskiportal_mobile/screens/user/user_page.dart';
import 'package:novinskiportal_mobile/models/article/news_mode.dart';
import 'package:novinskiportal_mobile/providers/article/news_provider.dart';
import 'package:novinskiportal_mobile/screens/article/home_page.dart';
import 'package:novinskiportal_mobile/screens/latest%20and%20most%20read/latest_news_page.dart';
import 'package:novinskiportal_mobile/screens/latest%20and%20most%20read/mostread_news_page.dart';
import 'package:novinskiportal_mobile/widgets/common/app_main_app_bar.dart';
import 'package:novinskiportal_mobile/widgets/navigation/hamburger_menu.dart';
import 'package:novinskiportal_mobile/widgets/navigation/main_bottom_nav.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  final List<String> _titles = [
    'Novinski portal',
    'Najnovije',
    'Najčitanije',
    'Profil',
  ];

  int _indexFromMode(NewsMode mode) {
    switch (mode) {
      case NewsMode.latest:
        return 1;
      case NewsMode.mostread:
        return 2;
    }
  }

  void _handleOpenNewsTab(NewsMode mode) {
    final index = _indexFromMode(mode);

    setState(() {
      _currentIndex = index;
    });
  }

  void _handleNewsModeChanged(NewsMode mode) {
    final index = _indexFromMode(mode);

    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          key: const Key('home_page'),
          onOpenNewsTab: _handleOpenNewsTab,
        );
      case 1:
        return ChangeNotifierProvider(
          create: (_) => NewsProvider(),
          child: LatestNewsPage(onModeChanged: _handleNewsModeChanged),
        );
      case 2:
        return ChangeNotifierProvider(
          create: (_) => NewsProvider(),
          child: MostReadNewsPage(onModeChanged: _handleNewsModeChanged),
        );
      case 3:
        return const UserPage();
      default:
        return HomePage(
          key: const Key('home_default'),
          onOpenNewsTab: _handleOpenNewsTab,
        );
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
        onSearchTap: _currentIndex == 3
            ? null
            : () {
                // ovdje kasnije ide search
              },
        actionIcon: Icons.search,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          final auth = context.read<AuthProvider>();

          if (index == 3 && !auth.isAuthenticated) {
            Navigator.pushNamed(context, '/welcome');
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
