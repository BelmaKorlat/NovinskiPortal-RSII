import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/app_assets.dart';
import 'package:novinskiportal_mobile/screens/news_report/news_report_page_scaffold.dart';
import 'package:novinskiportal_mobile/widgets/navigation/category_menu_section.dart';
import 'package:novinskiportal_mobile/screens/favorite/favorite_page_scaffold.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final logoPath = AppAssets.logoForTheme(theme);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Container(
        color: theme.drawerTheme.backgroundColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        logoPath,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Novinski portal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(child: CategoryMenuSection()),
              ),

              const Divider(height: 1),

              ListTile(
                leading: Icon(Icons.bookmark, color: cs.onSurface),
                title: const Text('Favoriti'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FavoritePageScaffold(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.add_circle_outline, color: cs.onSurface),
                title: const Text('Dojava vijesti'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NewsReportPageScaffold(),
                    ),
                  );
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: Icon(Icons.settings, color: cs.onSurface),
                title: const Text('Postavke'),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
