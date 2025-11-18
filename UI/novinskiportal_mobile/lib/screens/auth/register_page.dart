import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/core/notification_service.dart';
import 'package:provider/provider.dart';

import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nickController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _usernameExist;
  String? _emailExist;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final Validator firstNameValidator;
  late final Validator lastNameValidator;
  late final Validator usernameValidator;
  late final Validator emailValidator;
  late final Validator passwordValidator;
  late final Validator confirmPasswordValidator;

  @override
  void initState() {
    super.initState();

    firstNameValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 50)],
    );

    lastNameValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 50)],
    );

    usernameValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 100)],
    );

    emailValidator = Validator(
      validators: [RequiredValidator(), EmailValidator()],
    );

    passwordValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 6)],
    );

    confirmPasswordValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 6)],
    );
    _firstNameController.addListener(_updateNickFromName);
    _lastNameController.addListener(_updateNickFromName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nickController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateNickFromName() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();

    if (first.isEmpty || last.isEmpty) {
      _nickController.text = '';
      return;
    }

    final firstInitial = first[0].toUpperCase();
    final lastInitial = last[0].toUpperCase();

    final newNick = '$firstInitial.$lastInitial.';

    if (_nickController.text != newNick) {
      _nickController.text = newNick;
    }
  }

  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _usernameExist = null;
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final taken = await auth.isUsernameTaken(username);

    if (!mounted) return;

    setState(() {
      _usernameExist = taken ? 'Korisničko ime je već zauzeto.' : null;
    });

    _formKey.currentState?.validate();
  }

  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailExist = null;
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final taken = await auth.isEmailTaken(email);

    if (!mounted) return;

    setState(() {
      _emailExist = taken ? 'Email je već zauzet.' : null;
    });

    _formKey.currentState?.validate();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final auth = context.read<AuthProvider>();

    final req = RegisterRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      nick: _nickController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    try {
      await auth.register(req);
      if (!mounted) return;

      NotificationService.success('Notifikacija', 'Registracija uspješna');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on ApiException catch (ex) {
      if (!mounted) return;
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      if (!mounted) return;
      NotificationService.error(
        'Greška',
        'Došlo je do greške pri registraciji.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.isLoading;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      //appBar: AppBar(title: const Text('Registracija')),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        title: const Text('Registracija'),
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
                  // kartica sa formom
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
                            'Podaci za registraciju',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ime
                          TextFormField(
                            controller: _firstNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Ime',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => firstNameValidator.validate(
                              label: 'Ime',
                              value: v,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // prezime
                          TextFormField(
                            controller: _lastNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Prezime',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => lastNameValidator.validate(
                              label: 'Prezime',
                              value: v,
                            ),
                          ),
                          const SizedBox(height: 12),

                          //nadimak
                          TextFormField(
                            controller: _nickController,
                            readOnly: true,
                            enableInteractiveSelection: false,
                            decoration: const InputDecoration(
                              labelText: 'Nadimak',
                              prefixIcon: Icon(Icons.tag_faces_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // username
                          TextFormField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Korisničko ime',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            validator: (v) {
                              final error = usernameValidator.validate(
                                label: 'Korisničko ime',
                                value: v,
                              );
                              if (error != null) return error;

                              // ako backend kaže da je zauzeto
                              if (_usernameExist != null) {
                                return _usernameExist;
                              }
                              return null;
                            },
                            onChanged: (_) => _checkUsername(),
                            onFieldSubmitted: (_) => _checkUsername(),
                          ),
                          const SizedBox(height: 12),

                          // email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              final error = emailValidator.validate(
                                label: 'Email',
                                value: v,
                              );
                              if (error != null) return error;

                              if (_emailExist != null) {
                                return _emailExist;
                              }
                              return null;
                            },
                            onChanged: (_) => _checkEmail(),
                            onFieldSubmitted: (_) => _checkEmail(),
                          ),
                          const SizedBox(height: 12),

                          // lozinka
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
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
                            validator: (v) => passwordValidator.validate(
                              label: 'Lozinka',
                              value: v,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // potvrda lozinke
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Potvrdi lozinku',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirm = !_obscureConfirm;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (v) {
                              final error = confirmPasswordValidator.validate(
                                label: 'Potvrda lozinke',
                                value: v,
                              );
                              if (error != null) {
                                return error;
                              }

                              if (v != _passwordController.text) {
                                return 'Lozinke se ne poklapaju.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

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
                                  : const Text('Kreiraj račun'),
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
                        'Već imaš račun?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: Text(
                          'Prijavi se',
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
