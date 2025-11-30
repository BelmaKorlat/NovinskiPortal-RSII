import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../models/admin_user_models.dart';
import 'package:form_validation/form_validation.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  late UserAdminDto _userAdminDto;
  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;

  bool _inited = false;
  bool _saving = false;

  late final Validator newPasswordValidator;
  late final Validator confirmNewPasswordValidator;

  @override
  void initState() {
    super.initState();

    newPasswordValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 6)],
    );

    confirmNewPasswordValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 6)],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;

    _userAdminDto = ModalRoute.of(context)!.settings.arguments as UserAdminDto;

    _inited = true;
  }

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final req = AdminChangePasswordRequest(
        newPassword: _newPassword.text.trim(),
        confirmNewPassword: _confirmPassword.text.trim(),
      );

      await context.read<AdminUserProvider>().changePasswordForUser(
        _userAdminDto.id,
        req,
      );
      if (!mounted) return;
      Navigator.pop(context);
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
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset lozinke za ${_userAdminDto.username}',
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
                      child: const Text('Unesite novu lozinku'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _newPassword,
                              obscureText: _passwordObscured,
                              decoration: InputDecoration(
                                labelText: 'Nova lozinka',
                                suffixIcon: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => _passwordObscured = false),
                                  onTapUp: (_) =>
                                      setState(() => _passwordObscured = true),
                                  onTapCancel: () =>
                                      setState(() => _passwordObscured = true),
                                  behavior: HitTestBehavior.opaque,
                                  child: Icon(
                                    _passwordObscured
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              validator: (v) => newPasswordValidator.validate(
                                label: 'Nova lozinka',
                                value: v,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPassword,
                              obscureText: _confirmPasswordObscured,
                              decoration: InputDecoration(
                                labelText: 'Potvrda lozinke',
                                suffixIcon: GestureDetector(
                                  onTapDown: (_) => setState(
                                    () => _confirmPasswordObscured = false,
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
                                final error = confirmNewPasswordValidator
                                    .validate(
                                      label: 'Potvrda lozinke',
                                      value: v,
                                    );
                                if (error != null) return error;

                                if (v != _newPassword.text) {
                                  return 'Lozinke se ne poklapaju.';
                                }

                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _save(),
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
