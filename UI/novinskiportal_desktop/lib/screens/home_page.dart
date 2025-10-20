// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Tema toggle
          IconButton(
            tooltip: 'Tema',
            onPressed: () => context.read<ThemeProvider>().toggleLightDark(),
            icon: Icon(
              context.watch<ThemeProvider>().mode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          // Logout
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text('Dobrodošla, ${user?.username ?? 'user'}')),
    );
  }
}
