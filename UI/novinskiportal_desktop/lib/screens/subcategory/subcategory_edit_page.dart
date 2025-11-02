import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subcategory_models.dart';
import '../../providers/subcategory_provider.dart';
import 'package:form_validation/form_validation.dart';
import '../../core/api_error.dart';
import '../../core/notification_service.dart';
import '../../models/category_models.dart';
import '../../services/category_service.dart';

class EditSubcategoryPage extends StatefulWidget {
  const EditSubcategoryPage({super.key});

  @override
  State<EditSubcategoryPage> createState() => _EditSubcategoryPageState();
}

class _EditSubcategoryPageState extends State<EditSubcategoryPage> {
  final _form = GlobalKey<FormState>();

  late SubcategoryDto _sub;

  late final TextEditingController _ord;
  late final TextEditingController _name;

  int? _categoryId;
  bool _active = true;
  bool _saving = false;

  bool _categoryLoading = true;
  List<CategoryDto> _categories = [];

  late final Validator ordinalNumberValidator;
  late final Validator nameValidator;

  bool _inited = false;

  @override
  void initState() {
    super.initState();

    ordinalNumberValidator = Validator(
      validators: [RequiredValidator(), NumberValidator(allowDecimal: false)],
    );

    nameValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 50)],
    );

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final svc = CategoryService();
      final list = await svc.getList(
        const CategorySearch(retrieveAll: true, active: true),
      );
      setState(() {
        _categories = List<CategoryDto>.from(list)
          ..sort((a, b) => a.name.compareTo(b.name));
        _categoryLoading = false;
      });
    } catch (_) {
      setState(() => _categoryLoading = false);
      NotificationService.error('Greška', 'Ne mogu učitati kategorije.');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _sub = ModalRoute.of(context)!.settings.arguments as SubcategoryDto;
    _ord = TextEditingController(text: _sub.ordinalNumber.toString());
    _name = TextEditingController(text: _sub.name);
    _active = _sub.active;
    _categoryId = _sub.categoryId;

    _inited = true;
  }

  @override
  void dispose() {
    _ord.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final req = UpdateSubcategoryRequest(
        ordinalNumber: int.parse(_ord.text.trim()),
        name: _name.text.trim(),
        active: _active,
        categoryId: _categoryId!,
      );
      await context.read<SubcategoryProvider>().update(_sub.id, req);
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (ex) {
      if (!mounted) return;
      NotificationService.error('Greška', ex.message);
    } catch (_) {
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
                'Uredite potkategoriju',
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
                            SizedBox(
                              width: 380,
                              child: _categoryLoading
                                  ? const LinearProgressIndicator()
                                  : DropdownButtonFormField<int>(
                                      initialValue: _categoryId,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Kategorija',
                                      ),
                                      items: _categories
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c.id,
                                              child: Text(c.name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _categoryId = v),
                                      validator: (v) => v == null
                                          ? 'Odaberite kategoriju'
                                          : null,
                                    ),
                            ),
                            const SizedBox(height: 12),
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
