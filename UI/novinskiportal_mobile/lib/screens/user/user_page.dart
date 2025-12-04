import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_mobile/providers/auth/auth_provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final username = auth.user?.username ?? '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Prijavljeni ste kao:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await auth.logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Odjava'),
            ),
          ),
        ],
      ),
    );
  }
}
