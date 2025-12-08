import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unesite email')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await auth.forgotPassword(email);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Ako postoji nalog s tim emailom, poslali smo upute za reset lozinke.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške pri slanju zahtjeva.'),
        ),
      );
    } finally {
      if (!mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaboravljena lozinka'),
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unesite email adresu povezanu sa nalogom. '
                'Ako nalog postoji, poslat ćemo vam upute za reset lozinke.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Pošalji zahtjev'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
