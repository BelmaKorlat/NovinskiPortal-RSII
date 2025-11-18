import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../models/admin_user_models.dart';
import '../../core/api_error.dart';
import 'package:form_validation/form_validation.dart';
import '../../core/notification_service.dart';

class CreateAdminUserPage extends StatefulWidget {
  const CreateAdminUserPage({super.key});

  @override
  State<CreateAdminUserPage> createState() => _CreateAdminUserPageState();
}

class _CreateAdminUserPageState extends State<CreateAdminUserPage> {
  final _form = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _nick = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _roleController = TextEditingController(text: 'Admin');
  final int _roleId = 1;
  bool _active = true;
  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;
  bool _saving = false;

  String? _usernameExist;
  String? _emailExist;

  late final Validator firstNameValidator;
  late final Validator lastNameValidator;
  late final Validator nickValidator;
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

    nickValidator = Validator(
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

    _firstName.addListener(_updateNickFromName);
    _lastName.addListener(_updateNickFromName);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _nick.dispose();
    _username.dispose();
    _email.dispose();
    _roleController.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _updateNickFromName() {
    final first = _firstName.text.trim();
    final last = _lastName.text.trim();

    if (first.isEmpty || last.isEmpty) {
      _nick.text = '';
      return;
    }

    final firstInitial = first[0].toUpperCase();
    final lastInitial = last[0].toUpperCase();

    final newNick = '$firstInitial.$lastInitial.';

    if (_nick.text != newNick) {
      _nick.text = newNick;
    }
  }

  Future<void> _checkUsername() async {
    final username = _username.text.trim();

    if (username.isEmpty) {
      setState(() {
        _usernameExist = null;
      });
      return;
    }

    final auth = context.read<AdminUserProvider>();
    final taken = await auth.isUsernameTaken(username);

    if (!mounted) return;

    setState(() {
      _usernameExist = taken ? 'Korisničko ime je već zauzeto.' : null;
    });

    _form.currentState?.validate();
  }

  Future<void> _checkEmail() async {
    final email = _email.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailExist = null;
      });
      return;
    }

    final auth = context.read<AdminUserProvider>();
    final taken = await auth.isEmailTaken(email);

    if (!mounted) return;

    setState(() {
      _emailExist = taken ? 'Email je već zauzet.' : null;
    });

    _form.currentState?.validate();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final req = CreateAdminUserRequest(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        nick: _nick.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        roleId: _roleId,
        active: _active,
      );

      await context.read<AdminUserProvider>().create(req);
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (ex) {
      if (!mounted) return;
      NotificationService.error('Greška', ex.message);
    } catch (e) {
      if (!mounted) return;
      NotificationService.error('Greška', 'Greška pri snimanju.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Novi korisnik',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: cs.outlineVariant),
                        ),
                      ),
                      child: const Text('Unesite podatke'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstName,
                                    decoration: InputDecoration(
                                      labelText: 'Ime',
                                    ),
                                    validator: (v) => firstNameValidator
                                        .validate(label: 'Ime', value: v),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: TextFormField(
                                    controller: _lastName,
                                    decoration: InputDecoration(
                                      labelText: 'Prezime',
                                    ),
                                    validator: (v) => lastNameValidator
                                        .validate(label: 'Prezime', value: v),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _email,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
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
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: TextFormField(
                                    controller: _username,
                                    decoration: InputDecoration(
                                      labelText: 'Korisničko ime',
                                    ),
                                    validator: (v) {
                                      final error = usernameValidator.validate(
                                        label: 'Korisničko ime',
                                        value: v,
                                      );
                                      if (error != null) return error;

                                      if (_usernameExist != null) {
                                        return _usernameExist;
                                      }
                                      return null;
                                    },
                                    onChanged: (_) => _checkUsername(),
                                    onFieldSubmitted: (_) => _checkUsername(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nick,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Nick',
                                    ),
                                    validator: (v) => nickValidator.validate(
                                      label: 'Nick',
                                      value: v,
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: TextFormField(
                                    controller: _roleController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Uloga',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _password,
                                    obscureText: _passwordObscured,
                                    decoration: InputDecoration(
                                      labelText: 'Lozinka',
                                      suffixIcon: GestureDetector(
                                        onTapDown: (_) => setState(
                                          () => _passwordObscured = false,
                                        ),
                                        onTapUp: (_) => setState(
                                          () => _passwordObscured = true,
                                        ),
                                        onTapCancel: () => setState(
                                          () => _passwordObscured = true,
                                        ),
                                        behavior: HitTestBehavior.opaque,
                                        child: Icon(
                                          _passwordObscured
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                      ),
                                    ),
                                    validator: (v) => passwordValidator
                                        .validate(label: 'Lozinka', value: v),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: TextFormField(
                                    controller: _confirmPassword,
                                    obscureText: _confirmPasswordObscured,
                                    decoration: InputDecoration(
                                      labelText: 'Potvrda lozinke',
                                      suffixIcon: GestureDetector(
                                        onTapDown: (_) => setState(
                                          () =>
                                              _confirmPasswordObscured = false,
                                        ),
                                        onTapUp: (_) => setState(
                                          () => _confirmPasswordObscured = true,
                                        ),
                                        onTapCancel: () => setState(
                                          () => _confirmPasswordObscured = true,
                                        ),
                                        behavior: HitTestBehavior.opaque,
                                        child: Icon(
                                          _confirmPasswordObscured
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      final error = confirmPasswordValidator
                                          .validate(
                                            label: 'Potvrda lozinke',
                                            value: v,
                                          );
                                      if (error != null) {
                                        return error;
                                      }

                                      if (v != _password.text) {
                                        return 'Lozinke se ne poklapaju.';
                                      }

                                      return null;
                                    },
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Aktivan'),
                                const SizedBox(width: 8),
                                Checkbox(
                                  value: _active,
                                  onChanged: (v) =>
                                      setState(() => _active = v ?? false),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: cs.outlineVariant),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Odustani'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sačuvaj'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
