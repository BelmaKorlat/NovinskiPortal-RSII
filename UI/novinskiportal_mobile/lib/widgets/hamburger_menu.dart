import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/core/app_assets.dart';

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
              // ovdje će kasnije doći kategorije
              Expanded(
                child: ListView(
                  children: const [ListTile(title: Text('Kategorije'))],
                ),
              ),

              const Divider(height: 1),

              // Postavke
              ListTile(
                leading: const Icon(Icons.settings),
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
