import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/models/news_report_models.dart';
import 'package:novinskiportal_desktop/providers/admin_comment_detail_provider.dart';
import 'package:novinskiportal_desktop/providers/admin_comment_provider.dart';
import 'package:novinskiportal_desktop/providers/admin_dashboard_provider.dart';
import 'package:novinskiportal_desktop/providers/admin_user_provider.dart';
import 'package:novinskiportal_desktop/providers/article_provider.dart';
import 'package:novinskiportal_desktop/providers/category_provider.dart';
import 'package:novinskiportal_desktop/providers/news_report_provider.dart';
import 'package:novinskiportal_desktop/providers/subcategory_provider.dart';
import 'package:novinskiportal_desktop/screens/admin_comment/admin_comment_detail_page.dart';
import 'package:novinskiportal_desktop/screens/admin_comment/admin_comment_page.dart';
import 'package:novinskiportal_desktop/screens/admin_user/admin_user_create_page.dart';
import 'package:novinskiportal_desktop/screens/admin_user/admin_user_edit_page.dart';
import 'package:novinskiportal_desktop/screens/admin_user/admin_user_page.dart';
import 'package:novinskiportal_desktop/screens/admin_user/admin_user_reset_password_page.dart';
import 'package:novinskiportal_desktop/screens/article/article_create_page.dart';
import 'package:novinskiportal_desktop/screens/article/article_edit_page.dart';
import 'package:novinskiportal_desktop/screens/article/article_list_page.dart';
import 'package:novinskiportal_desktop/screens/category/category_list_page.dart';
import 'package:novinskiportal_desktop/screens/dashboard/admin_dashboard_page.dart';
import 'package:novinskiportal_desktop/screens/news_report/news_report_detail_page.dart';
import 'package:novinskiportal_desktop/screens/news_report/news_report_list_page.dart';
import 'package:novinskiportal_desktop/screens/subcategory/subcategory_edit_page.dart';
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
import 'screens/subcategory/subcategory_list_page.dart';
import 'screens/subcategory/subcategory_create_page.dart';

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
        ChangeNotifierProvider(create: (_) => SubcategoryProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => AdminUserProvider()),
        ChangeNotifierProvider(create: (_) => NewsReportProvider()),
        ChangeNotifierProvider(create: (_) => AdminCommentProvider()),
        ChangeNotifierProvider(create: (_) => AdminCommentDetailProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
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
        '/admin': (_) =>
            const AdminLayout(currentIndex: 0, child: DashboardPage()),

        '/categories': (_) =>
            const AdminLayout(currentIndex: 1, child: CategoryListPage()),
        '/categories/new': (_) =>
            const AdminLayout(currentIndex: 1, child: CreateCategoryPage()),
        '/categories/edit': (_) =>
            const AdminLayout(currentIndex: 1, child: EditCategoryPage()),
        '/subcategories': (_) =>
            const AdminLayout(currentIndex: 2, child: SubcategoryListPage()),
        '/subcategories/new': (_) =>
            const AdminLayout(currentIndex: 2, child: CreateSubcategoryPage()),
        '/subcategories/edit': (_) =>
            const AdminLayout(currentIndex: 2, child: EditSubcategoryPage()),

        '/articles': (_) =>
            const AdminLayout(currentIndex: 3, child: ArticleListPage()),
        '/articles/new': (_) =>
            const AdminLayout(currentIndex: 3, child: CreateArticlePage()),
        '/articles/edit': (_) =>
            const AdminLayout(currentIndex: 3, child: EditArticlePage()),

        '/admin/users': (_) =>
            const AdminLayout(currentIndex: 4, child: AdminUserListPage()),
        '/admin/users/new': (_) =>
            const AdminLayout(currentIndex: 4, child: CreateAdminUserPage()),
        '/admin/users/edit': (_) =>
            const AdminLayout(currentIndex: 4, child: EditAdminUserPage()),
        '/admin/users/change-password': (_) =>
            const AdminLayout(currentIndex: 4, child: ResetPasswordPage()),

        '/newsreport': (_) =>
            const AdminLayout(currentIndex: 5, child: NewsReportListPage()),

        '/news-reports/detail': (ctx) {
          final report =
              ModalRoute.of(ctx)!.settings.arguments as NewsReportDto;

          return AdminLayout(
            currentIndex: 5,
            child: NewsReportDetailPage(report: report),
          );
        },

        '/comments': (_) =>
            const AdminLayout(currentIndex: 6, child: AdminCommentListPage()),

        '/comments/detail': (_) =>
            const AdminLayout(currentIndex: 6, child: AdminCommentDetailPage()),
      },
    );
  }
}
