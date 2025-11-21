import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final mode = themeProvider.mode;
    final isDark = mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Postavke'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Text(
            'Pozadina',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tema'),
            subtitle: Text(
              isDark ? 'Tamna' : 'Svijetla',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            trailing: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: cs.primary,
            ),
            onTap: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              themeProvider.set(newMode);
            },
          ),
        ],
      ),
    );
  }
}
