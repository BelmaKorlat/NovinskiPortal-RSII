import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_models.dart';
import '../../utils/color_utils.dart';
import '../../widgets/dialogs/color_picker.dart';
import '../../core/api_error.dart';
import 'package:form_validation/form_validation.dart';
import '../../core/notification_service.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _form = GlobalKey<FormState>();
  final _ord = TextEditingController();
  final _name = TextEditingController();
  final _color = TextEditingController(text: '#3B82F6');
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
      final req = CreateCategoryRequest(
        ordinalNumber: int.parse(_ord.text.trim()),
        name: _name.text.trim(),
        color: _color.text.trim(),
        active: _active,
      );

      await context.read<CategoryProvider>().create(req);
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
                'Nova kategorija',
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
                            TextFormField(
                              controller: _ord,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
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
                              decoration: InputDecoration(labelText: 'Naziv'),
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
                                    shape: BoxShape.rectangle,
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
                                      setState(() => _color.text = picked);
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
