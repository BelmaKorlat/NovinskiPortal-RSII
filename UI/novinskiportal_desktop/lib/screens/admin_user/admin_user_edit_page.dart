import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../models/admin_user_models.dart';
import 'package:form_validation/form_validation.dart';
import 'package:intl/intl.dart';

class EditAdminUserPage extends StatefulWidget {
  const EditAdminUserPage({super.key});

  @override
  State<EditAdminUserPage> createState() => _EditAdminUserPageState();
}

class _EditAdminUserPageState extends State<EditAdminUserPage> {
  final _form = GlobalKey<FormState>();
  late UserAdminDto _userAdminDto;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _nick;
  late final TextEditingController _username;
  late final TextEditingController _email;

  int _roleId = 1;
  bool _active = true;

  bool _saving = false;

  bool _inited = false;

  late final Validator firstNameValidator;
  late final Validator lastNameValidator;
  late final Validator nickValidator;
  late final Validator usernameValidator;
  late final Validator emailValidator;

  @override
  void initState() {
    super.initState();

    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _nick = TextEditingController();
    _username = TextEditingController();
    _email = TextEditingController();

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

    _firstName.addListener(_updateNickFromName);
    _lastName.addListener(_updateNickFromName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _userAdminDto = ModalRoute.of(context)!.settings.arguments as UserAdminDto;
    _firstName.text = _userAdminDto.firstName;
    _lastName.text = _userAdminDto.lastName;
    _nick.text = _userAdminDto.nick;
    _username.text = _userAdminDto.username;
    _email.text = _userAdminDto.email;
    _roleId = _userAdminDto.roleId;
    _active = _userAdminDto.active;

    _inited = true;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _nick.dispose();
    _username.dispose();
    _email.dispose();
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

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final req = UpdateAdminUserRequest(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        nick: _nick.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        roleId: _roleId,
        active: _active,
      );

      await context.read<AdminUserProvider>().update(_userAdminDto.id, req);
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _unbanComments() async {
    setState(() => _saving = true);
    try {
      final provider = context.read<AdminUserProvider>();
      final fresh = await provider.unbanComments(_userAdminDto.id);

      if (!mounted) return;

      if (fresh != null) {
        setState(() {
          _userAdminDto = fresh;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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
                'Uredite korisnika',
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
                      child: const Text('Ažurirajte podatke'),
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
                                    validator: (v) => emailValidator.validate(
                                      label: 'Email',
                                      value: v,
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: TextFormField(
                                    controller: _username,
                                    decoration: InputDecoration(
                                      labelText: 'Korisničko ime',
                                    ),
                                    validator: (v) =>
                                        usernameValidator.validate(
                                          label: 'Korisničko ime',
                                          value: v,
                                        ),
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
                                  child: DropdownButtonFormField<int>(
                                    initialValue: _roleId,
                                    decoration: const InputDecoration(
                                      labelText: 'Uloga',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text('Admin'),
                                      ),
                                      DropdownMenuItem(
                                        value: 2,
                                        child: Text('Korisnik'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => _roleId = value);
                                    },
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

                            const SizedBox(height: 16),

                            Text(
                              'Zabrana komentarisanja',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),

                            const SizedBox(height: 8),

                            Builder(
                              builder: (context) {
                                final banUntil = _userAdminDto.commentBanUntil;
                                final banReason =
                                    _userAdminDto.commentBanReason;
                                final now = DateTime.now();

                                final hasActiveBan =
                                    banUntil != null && banUntil.isAfter(now);

                                if (!hasActiveBan) {
                                  return const Text(
                                    'Korisnik nema aktivnu zabranu komentarisanja.',
                                  );
                                }

                                final formattedDate = DateFormat(
                                  'dd.MM.yyyy. HH:mm',
                                ).format(banUntil.toLocal());

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Zabranjen do: $formattedDate'),
                                    if (banReason != null &&
                                        banReason.trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text('Razlog: $banReason'),
                                      ),
                                    const SizedBox(height: 8),
                                    FilledButton.tonal(
                                      onPressed: _saving
                                          ? null
                                          : _unbanComments,
                                      child: const Text(
                                        'Ukloni zabranu komentarisanja',
                                      ),
                                    ),
                                  ],
                                );
                              },
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
