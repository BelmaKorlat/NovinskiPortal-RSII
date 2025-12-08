import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_validation/form_validation.dart';
import 'package:novinskiportal_mobile/providers/user/user_profile_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  late final Validator _requiredValidator;
  late final Validator _newPasswordValidator;

  @override
  void initState() {
    super.initState();

    _requiredValidator = Validator(validators: [RequiredValidator()]);

    _newPasswordValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 6)],
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword(UserProfileProvider provider) async {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    final success = await provider.changePassword(
      currentPassword: current,
      newPassword: newPass,
      confirmNewPassword: confirm,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lozinka je promijenjena.')));

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      Navigator.of(context).pop();
    } else {
      final msg = provider.error ?? 'Greška pri promjeni lozinke.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProfileProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final loading = provider.isChangingPassword;

    return Scaffold(
      appBar: AppBar(title: const Text('Promjena lozinke')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (theme.brightness == Brightness.light)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                        ],
                        border: theme.brightness == Brightness.dark
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Promijeni lozinku',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: !_showCurrentPassword,
                            decoration: InputDecoration(
                              labelText: 'Trenutna lozinka',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showCurrentPassword =
                                        !_showCurrentPassword;
                                  });
                                },
                                icon: Icon(
                                  _showCurrentPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              return _requiredValidator.validate(
                                label: 'Trenutna lozinka',
                                value: value,
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_showNewPassword,
                            decoration: InputDecoration(
                              labelText: 'Nova lozinka',
                              prefixIcon: const Icon(Icons.lock_reset),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showNewPassword = !_showNewPassword;
                                  });
                                },
                                icon: Icon(
                                  _showNewPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              return _newPasswordValidator.validate(
                                label: 'Nova lozinka',
                                value: value,
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Potvrdi novu lozinku',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showConfirmPassword =
                                        !_showConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _showConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final baseError = _requiredValidator.validate(
                                label: 'Potvrda lozinke',
                                value: value,
                              );
                              if (baseError != null) return baseError;

                              if (value != _newPasswordController.text) {
                                return 'Nova lozinka i potvrda se ne poklapaju.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          if (provider.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                provider.error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.error,
                                ),
                              ),
                            ),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () => _handleChangePassword(provider),
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sačuvaj novu lozinku'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
