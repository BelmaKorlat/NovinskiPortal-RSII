import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:novinskiportal_mobile/core/app_theme.dart';
import 'package:novinskiportal_mobile/core/dev_http_overrides.dart';
import 'package:novinskiportal_mobile/providers/article/article_provider.dart';
import 'package:novinskiportal_mobile/providers/article/category_articles_provider.dart';
import 'package:novinskiportal_mobile/providers/article/news_provider.dart';
import 'package:novinskiportal_mobile/providers/category/category_menu_provider.dart';
import 'package:novinskiportal_mobile/providers/settings/theme_provider.dart';
import 'package:novinskiportal_mobile/screens/article/home_page.dart';
import 'package:novinskiportal_mobile/screens/article/news_page.dart';
import 'package:novinskiportal_mobile/screens/auth/login_page.dart';
import 'package:novinskiportal_mobile/screens/auth/register_page.dart';
import 'package:novinskiportal_mobile/screens/auth/welcome_page.dart';
import 'package:novinskiportal_mobile/screens/main/main_layout.dart';
import 'package:novinskiportal_mobile/screens/settings/settings_page.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/notification_service.dart';
import 'providers/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = DevHttpOverrides();

  final themeProvider = ThemeProvider();
  await themeProvider.load();

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
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => CategoryArticlesProvider()),
        ChangeNotifierProvider(create: (_) => CategoryMenuProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: const NovinskiPortalMobileApp(),
    ),
  );
}

class NovinskiPortalMobileApp extends StatelessWidget {
  const NovinskiPortalMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Novinski portal',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,
      home: const WelcomePage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/welcome': (_) => const WelcomePage(),
        '/home': (_) => const HomePage(),
        '/settings': (_) => const SettingsPage(),
        '/main': (_) => const MainLayout(),
        '/newsScreen': (_) => const NewsPage(),
      },
    );
  }
}
