import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';

void showToastTopRight(
  BuildContext context,
  String message, {
  int seconds = 3,
}) {
  final overlay = Overlay.of(context); // nenull u sklopu MaterialApp/Scaffold

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

      showToastTopRight(context, 'Login uspješan', seconds: 3);

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      showToastTopRight(context, msg); // greška gore desno
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _userCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Username ili email',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Unesi username ili email';
                        if (s.contains('@')) {
                          final ok = RegExp(
                            r'^[^@]+@[^@]+\.[^@]+$',
                          ).hasMatch(s);
                          if (!ok) return 'Email nije ispravan';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: MouseRegion(
                          onEnter: (_) => setState(() => _obscure = false),
                          onExit: (_) => setState(() => _obscure = true),
                          child: IconButton(
                            onPressed:
                                () {}, // klik ne radi ništa, prikaz je samo na hover
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            tooltip: 'Pređi mišem za prikaz',
                          ),
                        ),
                      ),
                      validator: (v) {
                        final s = v ?? '';
                        if (s.isEmpty) return 'Unesi password';
                        if (s.length < 6) return 'Minimalno 6 znakova';
                        return null;
                      },
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
