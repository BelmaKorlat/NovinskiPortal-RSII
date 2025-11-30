import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_models.dart';
import '../../providers/category_provider.dart';
import '../../utils/color_utils.dart';
import '../../widgets/dialogs/color_picker.dart';
import 'package:form_validation/form_validation.dart';

class EditCategoryPage extends StatefulWidget {
  const EditCategoryPage({super.key});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _form = GlobalKey<FormState>();
  bool _inited = false;
  late final TextEditingController _ord;
  late final TextEditingController _name;
  late final TextEditingController _color;
  late CategoryDto _cat;
  bool _active = true;
  bool _saving = false;
  late final Validator ordinalNumberValidator;
  late final Validator nameValidator;

  @override
  void initState() {
    super.initState();

    ordinalNumberValidator = Validator(
      validators: [RequiredValidator(), NumberValidator(allowDecimal: false)],
    );

    nameValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 50)],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _cat = ModalRoute.of(context)!.settings.arguments as CategoryDto;
    _ord = TextEditingController(text: _cat.ordinalNumber.toString());
    _name = TextEditingController(text: _cat.name);
    _color = TextEditingController(text: _cat.color);
    _active = _cat.active;

    _color.addListener(() => setState(() {}));
    _inited = true;
  }

  @override
  void dispose() {
    _ord.dispose();
    _name.dispose();
    _color.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final req = UpdateCategoryRequest(
        ordinalNumber: int.tryParse(_ord.text) ?? 0,
        name: _name.text.trim(),
        color: _color.text.trim(),
        active: _active,
      );
      await context.read<CategoryProvider>().update(_cat.id, req);
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
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uredite kategoriju',
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
                            TextFormField(
                              controller: _ord,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Redni broj',
                              ),
                              validator: (v) => ordinalNumberValidator.validate(
                                label: 'Redni broj',
                                value: v,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: 'Naziv',
                              ),
                              validator: (v) => nameValidator.validate(
                                label: 'Naziv',
                                value: v,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color:
                                        tryParseHexColor(_color.text) ??
                                        cs.primary,
                                    border: Border.all(
                                      color: cs.outlineVariant,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _color,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Boja',
                                    ),
                                    validator: (v) =>
                                        tryParseHexColor(v ?? '') == null
                                        ? 'Neispravan hex'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.color_lens, size: 18),
                                  label: const Text('Izaberi'),
                                  onPressed: () async {
                                    final picked = await pickHexColor(
                                      context,
                                      _color.text,
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _color.text = picked;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Aktivna'),
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
