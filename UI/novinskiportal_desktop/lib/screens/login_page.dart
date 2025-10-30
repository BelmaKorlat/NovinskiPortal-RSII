import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/api_error.dart';
import '../core/notification_service.dart';
import 'package:form_validation/form_validation.dart';

void showToastTopRight(
  BuildContext context,
  String message, {
  int seconds = 3,
}) {
  final overlay = Overlay.of(context);

  final topSafe = MediaQuery.of(context).viewPadding.top;

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      top: topSafe + 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(Duration(seconds: seconds)).then((_) {
    if (entry.mounted) entry.remove();
  });
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  Timer? _revealTimer;
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
    _revealTimer?.cancel();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.login(_userCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;

      NotificationService.success('Notifikacija', 'Login uspješan');
      Navigator.pushNamedAndRemoveUntil(context, '/admin', (_) => false);
    } on ApiException catch (ex) {
      if (!mounted) return;
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      if (!mounted) return;
      NotificationService.error('Greška', 'Greška pri prijavi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/novinskiportal_logo_white_shaded.png'
        : 'assets/novinskiportal_logo_transparent.png';

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(assetPath, width: 120),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _userCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Korisničko ime ili email',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
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
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Lozinka',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: GestureDetector(
                          onTapDown: (_) => setState(() => _obscure = false),
                          onTapUp: (_) => setState(() => _obscure = true),
                          onTapCancel: () => setState(() => _obscure = true),
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) => passwordValidator.validate(
                        label: 'Lozinka',
                        value: v,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
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
