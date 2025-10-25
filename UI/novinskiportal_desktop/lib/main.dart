import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/providers/category_provider.dart';
import 'package:novinskiportal_desktop/screens/categories_page.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'screens/login_page.dart';
import 'screens/admin_layout.dart';
import 'screens/category_create_page.dart'; // nova stranica
import 'screens/category_edit_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: context.watch<ThemeProvider>().mode,
      home: const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/admin': (_) => const AdminLayout(
          currentIndex: 0,
          child: Center(child: Text('Početna')),
        ),

        // privremeni placeholderi da sidebar radi bez greške
        '/categories': (_) =>
            const AdminLayout(currentIndex: 1, child: CategoriesPage()),
        '/categories/new': (_) =>
            const AdminLayout(currentIndex: 1, child: CreateCategoryPage()),
        '/categories/edit': (_) =>
            const AdminLayout(currentIndex: 1, child: EditCategoryPage()),
        '/subcategories': (_) => const AdminLayout(
          currentIndex: 2,
          child: Center(child: Text('Potkategorije')),
        ),
        '/articles': (_) => const AdminLayout(
          currentIndex: 3,
          child: Center(child: Text('Članci')),
        ),
        '/users': (_) => const AdminLayout(
          currentIndex: 4,
          child: Center(child: Text('Korisnici')),
        ),
        '/comments': (_) => const AdminLayout(
          currentIndex: 5,
          child: Center(child: Text('Komentari')),
        ),
      },
    );
  }
}
