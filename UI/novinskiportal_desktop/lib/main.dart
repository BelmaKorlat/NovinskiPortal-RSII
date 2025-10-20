import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'core/api_client.dart';
import 'screens/login_page.dart';
import 'providers/theme_provider.dart';
import 'core/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
      ],
      child: const LoginApp(),
    ),
  );
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>(); // čita odabrani mod

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(), // iz core/app_theme.dart
      darkTheme: buildDarkTheme(), // iz core/app_theme.dart
      themeMode: theme.mode, // light/dark/system
      home: const LoginPage(),
    );
  }
}
