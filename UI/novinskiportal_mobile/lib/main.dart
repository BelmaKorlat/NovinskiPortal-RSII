import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:novinskiportal_mobile/core/app_theme.dart';
import 'package:novinskiportal_mobile/screens/auth/login_page.dart';
import 'package:novinskiportal_mobile/screens/auth/register_page.dart';
import 'package:novinskiportal_mobile/screens/auth/welcome_page.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/notification_service.dart';
import 'providers/auth_provider.dart';

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
      ],
      child: const NovinskiPortalMobileApp(),
    ),
  );
}

class NovinskiPortalMobileApp extends StatelessWidget {
  const NovinskiPortalMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novinski portal',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light, // kasnije ćeš ovo mijenjati preko providera
      home: const WelcomePage(),
      // ovdje kasnije možeš dodati routes za mobilni ako ti zatrebaju
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const WelcomePage(),
      },
    );
  }
}
