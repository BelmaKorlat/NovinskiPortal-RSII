import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/providers/category_provider.dart';
import 'package:novinskiportal_desktop/screens/category/category_list_page.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'screens/login_page.dart';
import 'screens/admin_layout.dart';
import 'screens/category/category_create_page.dart';
import 'screens/category/category_edit_page.dart';
import 'core/notification_service.dart';
import 'package:form_validation/form_validation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient();

  final t = FormValidationTranslations.values;
  t['form_validation_required'] = '{label} je obavezno polje.';
  t['form_validation_max_length'] =
      '{label} smije imati najviše {length} znakova.';
  t['form_validation_min_length'] =
      '{label} mora imati najmanje {length} znakova.';
  t['form_validation_min_number'] = '{label} mora biti najmanje {number}.';
  t['form_validation_number'] = '{label} mora biti broj.';
  t['form_validation_email'] = 'Neispravan email format.';
  t['form_validation_phone_number'] = 'Neispravan broj telefona.';

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
      navigatorKey: NotificationService.navigatorKey,
      home: const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/admin': (_) => const AdminLayout(
          currentIndex: 0,
          child: Center(child: Text('Početna')),
        ),

        '/categories': (_) =>
            const AdminLayout(currentIndex: 1, child: CategoryListPage()),
        '/categories/new': (_) =>
            const AdminLayout(currentIndex: 1, child: CreateCategoryPage()),
        '/categories/edit': (_) =>
            const AdminLayout(currentIndex: 1, child: EditCategoryPage()),
        '/subcategories': (_) => const AdminLayout(
          currentIndex: 2,
          child: Center(child: Text('Potkategorije')),
        ),
        // privremeni placeholderi da sidebar radi bez greške
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
