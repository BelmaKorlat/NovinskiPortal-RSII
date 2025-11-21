import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/core/notification_service.dart';
import 'package:provider/provider.dart';

import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final _forgotEmailController = TextEditingController();

  late final Validator emailValidator;
  late final Validator usernameValidator;
  late final Validator passwordValidator;

  @override
  void initState() {
    super.initState();

    emailValidator = Validator(
      validators: [RequiredValidator(), EmailValidator()],
    );

    usernameValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 3)],
    );

    passwordValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 6)],
    );
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final auth = context.read<AuthProvider>();

    final req = LoginRequest(
      emailOrUsername: _emailOrUsernameController.text.trim(),
      password: _passwordController.text,
    );

    try {
      await auth.login(req);
      if (!mounted) return;

      //NotificationService.success('Notifikacija', 'Login uspješan');
      // ruta na home page kasnije
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on ApiException catch (ex) {
      if (!mounted) return;
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      if (!mounted) return;
      NotificationService.error('Greška', 'Došlo je do greške pri prijavi.');
    }
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Zaboravljena lozinka'),
          content: TextField(
            controller: _forgotEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                final email = _forgotEmailController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unesite email')),
                  );
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);
                final auth = context.read<AuthProvider>();

                Navigator.of(ctx).pop();
                try {
                  await auth.forgotPassword(email);

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ako postoji nalog s tim emailom, poslali smo upute za reset lozinke.',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Došlo je do greške pri slanju zahtjeva.'),
                    ),
                  );
                }
              },
              child: const Text('Pošalji'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.isLoading;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      //appBar: AppBar(title: const Text('Prijava')),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (route) => false,
            );
          },
        ),
        title: const Text('Prijava'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // card sa formom
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                      ],
                      border: isDark
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            )
                          : null,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Podaci za prijavu',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // email / username
                          TextFormField(
                            controller: _emailOrUsernameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email ili korisničko ime',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              final s = value?.trim() ?? '';

                              if (s.contains('@')) {
                                return emailValidator.validate(
                                  label: 'Email',
                                  value: s,
                                );
                              }
                              return usernameValidator.validate(
                                label: 'Korisničko ime',
                                value: s,
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // lozinka
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Lozinka',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              return passwordValidator.validate(
                                label: 'Lozinka',
                                value: value,
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                _showForgotPasswordDialog(context);
                              },
                              child: Text(
                                'Zaboravljena lozinka?',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: loading ? null : _submit,
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Prijavi se'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nemaš račun?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: Text(
                          'Registruj se',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
