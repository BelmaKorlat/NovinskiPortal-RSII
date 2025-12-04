import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:novinskiportal_mobile/providers/auth/auth_provider.dart';
import 'package:novinskiportal_mobile/providers/news_report/news_report_provider.dart';
import 'package:provider/provider.dart';

class NewsReportPage extends StatefulWidget {
  const NewsReportPage({super.key});

  @override
  State<NewsReportPage> createState() => NewsReportPageState();
}

class NewsReportPageState extends State<NewsReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _textController = TextEditingController();

  late final Validator textValidator;
  late final Validator emailValidator;

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();

    textValidator = Validator(
      validators: [RequiredValidator(), MinLengthValidator(length: 10)],
    );

    emailValidator = Validator(
      validators: [RequiredValidator(), EmailValidator()],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _enableAutovalidation() {
    if (_autoValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  void resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _emailController.clear();
      _textController.clear();
      _autoValidateMode = AutovalidateMode.disabled;
    });
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<NewsReportProvider>();
    if (provider.isSubmitting) return;
    final messenger = ScaffoldMessenger.of(context);

    final bool isLoggedIn = auth.isAuthenticated;

    final String text = _textController.text.trim();
    final String? email = isLoggedIn ? null : _emailController.text.trim();

    final ok = await provider.submit(text: text, email: email);

    messenger.clearSnackBars();

    if (ok) {
      resetForm();

      messenger.showSnackBar(
        const SnackBar(content: Text('Hvala, tvoja dojava je poslana.')),
      );
    } else {
      final msg = provider.error ?? 'Došlo je do greške pri slanju dojave.';

      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsReportProvider>();
    final auth = context.watch<AuthProvider>();
    final bool isLoggedIn = auth.isAuthenticated;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bili ste svjedok važnog događaja\nili imate zanimljivu informaciju?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dojavite nam vijest i postanite dio Novinskog portala.\n'
                      'Vaša priča može biti važna za našu zajednicu.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              if (!isLoggedIn)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Unesite email',
                  ),
                  validator: (value) {
                    return emailValidator.validate(
                      label: 'Email',
                      value: value,
                    );
                  },
                  onChanged: (_) => _enableAutovalidation(),
                ),
              if (!isLoggedIn) const SizedBox(height: 16),

              TextFormField(
                controller: _textController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Tekst dojave',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  return textValidator.validate(
                    label: 'Tekst dojave',
                    value: value,
                  );
                },
                onChanged: (_) => _enableAutovalidation(),
              ),

              const SizedBox(height: 16),
              Text(
                'Priložite fajlove (slike ili PDF):',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: provider.isSubmitting
                        ? null
                        : provider.pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Odaberite fajlove'),
                  ),
                  const SizedBox(width: 12),
                  if (provider.files.isNotEmpty)
                    Text(
                      '${provider.files.length} fajl(a) odabrano',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),

              const SizedBox(height: 8),

              if (provider.files.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 4),
                    ...provider.files.asMap().entries.map((entry) {
                      final index = entry.key;
                      final f = entry.value;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          f.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: provider.isSubmitting
                              ? null
                              : () => provider.removeFileAt(index),
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
