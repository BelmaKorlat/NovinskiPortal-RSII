import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/models/user/user_models.dart';
import 'package:novinskiportal_mobile/screens/user/change_password_page.dart';
import 'package:provider/provider.dart';

import 'package:novinskiportal_mobile/providers/user/user_profile_provider.dart';
import 'package:novinskiportal_mobile/providers/auth/auth_provider.dart';
import 'package:novinskiportal_mobile/providers/favorite/favorite_provider.dart';
import 'package:novinskiportal_mobile/widgets/common/user_avatar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;

  bool _initializedFields = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _fillFieldsOnce(UserDto user) {
    if (_initializedFields) return;

    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _usernameController.text = user.username;

    _initializedFields = true;
  }

  Future<void> _handleSave(UserProfileProvider provider) async {
    FocusScope.of(context).unfocus();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sva polja su obavezna.')));
      return;
    }

    final ok = await provider.updateProfile(
      firstName: firstName,
      lastName: lastName,
      username: username,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil je sačuvan.')));

      final auth = context.read<AuthProvider>();
      final updated = provider.user;
      if (updated != null) {
        auth.setUserFromProfile(updated);
      }
    } else {
      final msg = provider.error ?? 'Greška pri čuvanju profila.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthProvider>();
    final favs = context.read<FavoritesProvider>();
    final navigator = Navigator.of(context);

    await auth.logout();
    favs.clearAll();

    navigator.pushNamedAndRemoveUntil('/welcome', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (profile.isLoading && profile.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile.error != null && profile.user == null) {
      return Center(child: Text(profile.error!));
    }

    final user = profile.user;
    if (user == null) {
      return const Center(child: Text('Nije moguće učitati profil.'));
    }

    _fillFieldsOnce(user);

    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : user.username;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              Center(child: UserAvatar(username: displayName, radius: 40)),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),

              Center(
                child: Text(
                  user.username,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 16),

              Text(
                'Podaci o profilu',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ime',
                  hintText: 'Unesite ime',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Prezime',
                  hintText: 'Unesite prezime',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Korisničko ime',
                  hintText: 'Unesite korisničko ime',
                ),
              ),

              const SizedBox(height: 16),

              if (profile.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    profile.error!,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                  ),
                ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profile.isSaving
                      ? null
                      : () => _handleSave(profile),
                  child: profile.isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sačuvaj'),
                ),
              ),

              const SizedBox(height: 32),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 16),

              Text(
                'Račun',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final profileProvider = context.read<UserProfileProvider>();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChangeNotifierProvider.value(
                          value: profileProvider,
                          child: const ChangePasswordPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Promijeni lozinku'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Odjava'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
