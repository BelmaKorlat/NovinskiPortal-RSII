import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:form_validation/form_validation.dart';

import '../../providers/article_provider.dart';
import '../../models/article_models.dart';
import '../../core/api_error.dart';
import '../../core/notification_service.dart';

import '../../services/category_service.dart';
import '../../models/category_models.dart';
import '../../services/subcategory_service.dart';
import '../../models/subcategory_models.dart';
import '../../providers/auth_provider.dart';

// Ako imaš UserService i UserDto, odkomentariši:
// import '../../services/user_service.dart';
// import '../../models/user_models.dart';

class EditArticlePage extends StatefulWidget {
  const EditArticlePage({super.key});

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _form = GlobalKey<FormState>();

  late ArticleDetailDto _art;
  late int _articleId;

  late final TextEditingController _headline;
  late final TextEditingController _subheadline;
  late final TextEditingController _shortText;
  late final TextEditingController _text;

  DateTime _publishedAt = DateTime.now().toLocal();

  bool _active = true;
  bool _hideFullName = false;
  bool _breakingNews = false;
  bool _live = false;

  int? _categoryId;
  int? _subcategoryId;
  //int? _userId; // uraditi kasnije
  bool _categoryLoading = true;
  bool _subcategoryLoading = true;
  // bool _userLoading = true;
  List<CategoryDto> _categories = [];
  List<SubcategoryDto> _subcategories = [];
  // List<UserDto> _users = [];

  String? _existingMainPhotoPath;
  List<String> _existingAdditionalPhotos = [];
  // slike
  PhotoUpload? _newMainPhoto;
  final List<PhotoUpload> _newAdditionalPhotos = [];

  bool _saving = false;
  bool _inited = false;

  late final Validator _headlineValidator;
  late final Validator _subheadlineValidator;
  late final Validator _shortTextValidator;
  late final Validator _textValidator;

  final _dateTimeFormat = DateFormat('d.M.yyyy. HH:mm');

  @override
  void initState() {
    super.initState();

    _headline = TextEditingController();
    _subheadline = TextEditingController();
    _shortText = TextEditingController();
    _text = TextEditingController();

    _headlineValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 150)],
    );
    _subheadlineValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 200)],
    );
    _shortTextValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 300)],
    );
    _textValidator = Validator(validators: [RequiredValidator()]);

    _loadCategories();
    //_loadSubcategories();
    // _loadUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    _art = ModalRoute.of(context)!.settings.arguments as ArticleDetailDto;
    _articleId = _art.id;

    _categoryId = _art.categoryId;
    _subcategoryId = _art.subcategoryId;
    _publishedAt = _art.publishedAt.toLocal();

    _headline.text = _art.headline;
    _subheadline.text = _art.subheadline;
    _shortText.text = _art.shortText;
    _text.text = _art.text;

    _active = _art.active;
    _hideFullName = _art.hideFullName;
    _breakingNews = _art.breakingNews;
    _live = _art.live;

    _existingMainPhotoPath = _art.mainPhotoPath;
    _existingAdditionalPhotos = List<String>.from(_art.additionalPhotos);

    _loadSubcategories(categoryIdFilter: _categoryId);

    _inited = true;
  }

  @override
  void dispose() {
    _headline.dispose();
    _subheadline.dispose();
    _shortText.dispose();
    _text.dispose();

    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final svc = CategoryService();
      final list = await svc.getList(
        const CategorySearch(retrieveAll: true, active: true),
      );
      setState(() {
        _categories = List<CategoryDto>.from(list)
          ..sort((a, b) {
            final an = a.name.trim().toLowerCase();
            final bn = b.name.trim().toLowerCase();
            return an.compareTo(bn);
          });
        _categoryLoading = false;
      });
    } catch (_) {
      setState(() => _categoryLoading = false);
      NotificationService.error('Greška', 'Ne mogu učitati kategorije.');
    }
  }

  Future<void> _loadSubcategories({int? categoryIdFilter}) async {
    try {
      final svc = SubcategoryService();
      final search = SubcategorySearch(
        retrieveAll: true,
        active: true,
        categoryId: categoryIdFilter,
      );
      final list = await svc.getList(search);
      setState(() {
        _subcategories = List<SubcategoryDto>.from(list)
          ..sort((a, b) {
            final an = a.name.trim().toLowerCase();
            final bn = b.name.trim().toLowerCase();
            return an.compareTo(bn);
          });
        _subcategoryLoading = false;
      });
    } catch (_) {
      setState(() => _subcategoryLoading = false);
      NotificationService.error('Greška', 'Ne mogu učitati potkategorije.');
    }
  }

  // Ako imaš listu korisnika, odkomentariši i prilagodi:
  // Future<void> _loadUsers() async {
  //   try {
  //     final svc = UserService();
  //     final list = await svc.getList();
  //     setState(() {
  //       _users = List<UserDto>.from(list)..sort((a, b) => a.fullName.compareTo(b.fullName));
  //       _userLoading = false;
  //     });
  //   } catch (_) {
  //     setState(() => _userLoading = false);
  //     NotificationService.error('Greška', 'Ne mogu učitati autore.');
  //   }
  // }

  // File picker helpers
  Future<PhotoUpload?> _pickOne() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    if (f.bytes != null) {
      return PhotoUpload(fileName: f.name, bytes: f.bytes!);
    }
    if (f.path != null) {
      final bytes = await File(f.path!).readAsBytes();
      return PhotoUpload(fileName: f.name, bytes: bytes);
    }
    return null;
  }

  Future<List<PhotoUpload>> _pickMany() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    if (res == null || res.files.isEmpty) return [];
    final additionalPhotos = <PhotoUpload>[];
    for (final f in res.files) {
      if (f.bytes != null) {
        additionalPhotos.add(PhotoUpload(fileName: f.name, bytes: f.bytes!));
      } else if (f.path != null) {
        final bytes = await File(f.path!).readAsBytes();
        additionalPhotos.add(PhotoUpload(fileName: f.name, bytes: bytes));
      }
    }
    return additionalPhotos;
  }

  Future<void> _pickMainPhoto() async {
    final p = await _pickOne();
    if (p == null) return;
    setState(() {
      _newMainPhoto = p;
      _existingMainPhotoPath = null;
    });
  }

  Future<void> _pickGallery() async {
    final many = await _pickMany();
    if (many.isEmpty) return;
    setState(() {
      _newAdditionalPhotos.addAll(many);
    });
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _publishedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (d == null) return;
    if (!mounted) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_publishedAt),
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
    if (t == null) return;
    if (!mounted) return;

    setState(() {
      _publishedAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.userId;

    if (userId == null || userId == 0) {
      NotificationService.error(
        'Greška',
        'Nije moguće odrediti autora. Prijavite se ponovo.',
      );
      return;
    }
    if (_categoryId == null) {
      NotificationService.error('Greška', 'Odaberite kategoriju.');
      return;
    }
    if (_subcategoryId == null) {
      NotificationService.error('Greška', 'Odaberite potkategoriju.');
      return;
    }
    // Ako nemaš dropdown za autora, postavi userId iz logina ili fiksno:
    //final userId = _userId ?? 1; // zamijeni stvarnim id iz AuthProvidera

    setState(() => _saving = true);
    try {
      final req = UpdateArticleRequest(
        headline: _headline.text.trim(),
        subheadline: _subheadline.text.trim(),
        shortText: _shortText.text.trim(),
        text: _text.text.trim(),
        publishedAt: _publishedAt.toLocal(),
        active: _active,
        hideFullName: _hideFullName,
        breakingNews: _breakingNews,
        live: _live,
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
        userId: userId,
        mainPhoto: _newMainPhoto,
        additionalPhotos: _newAdditionalPhotos.isNotEmpty
            ? _newAdditionalPhotos
            : null,
      );

      await context.read<ArticleProvider>().update(_articleId, req);
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

    final selectedCategoryId =
        (_categoryId != null && _categories.any((c) => c.id == _categoryId))
        ? _categoryId
        : null;

    final selectedSubcategoryId =
        (_subcategoryId != null &&
            _subcategories.any((s) => s.id == _subcategoryId))
        ? _subcategoryId
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uredite članak',
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
                                  child: _categoryLoading
                                      ? const LinearProgressIndicator()
                                      : DropdownButtonFormField<int>(
                                          initialValue: selectedCategoryId,
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
                                          onChanged: (v) {
                                            setState(() {
                                              _categoryId = v;
                                              _subcategoryId = null;
                                              _subcategoryLoading = true;
                                            });
                                            _loadSubcategories(
                                              categoryIdFilter: v,
                                            );
                                          },
                                          validator: (v) => v == null
                                              ? 'Odaberite kategoriju'
                                              : null,
                                        ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: _subcategoryLoading
                                      ? const LinearProgressIndicator()
                                      : DropdownButtonFormField<int>(
                                          initialValue: selectedSubcategoryId,
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Potkategorija',
                                          ),
                                          items: _subcategories
                                              .map(
                                                (s) => DropdownMenuItem(
                                                  value: s.id,
                                                  child: Text(s.name),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(
                                            () => _subcategoryId = v,
                                          ),
                                          validator: (v) => v == null
                                              ? 'Odaberite potkategoriju'
                                              : null,
                                        ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _subheadline,
                                    decoration: const InputDecoration(
                                      labelText: 'Nadnaslov',
                                    ),
                                    validator: (v) => _subheadlineValidator
                                        .validate(label: 'Nadnaslov', value: v),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickDateTime,
                                    borderRadius: BorderRadius.circular(8),
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Datum i vrijeme objave',
                                        ),
                                        controller: TextEditingController(
                                          text: _dateTimeFormat.format(
                                            _publishedAt,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _headline,
                              decoration: const InputDecoration(
                                labelText: 'Naslov',
                              ),
                              validator: (v) => _headlineValidator.validate(
                                label: 'Naslov',
                                value: v,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _shortText,
                              decoration: const InputDecoration(
                                labelText: 'Kratki tekst',
                              ),
                              validator: (v) => _shortTextValidator.validate(
                                label: 'Kratki tekst',
                                value: v,
                              ),
                              textInputAction: TextInputAction.next,
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _text,
                              minLines: 5,
                              maxLines: 12,
                              decoration: const InputDecoration(
                                labelText: 'Sadržaj',
                                alignLabelWithHint: true,
                              ),
                              validator: (v) => _textValidator.validate(
                                label: 'Sadržaj',
                                value: v,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _Flag(
                                  label: 'Aktivna',
                                  value: _active,
                                  onChanged: (v) => setState(() => _active = v),
                                ),
                                _Flag(
                                  label: 'Sakrij puno ime',
                                  value: _hideFullName,
                                  onChanged: (v) =>
                                      setState(() => _hideFullName = v),
                                ),
                                _Flag(
                                  label: 'Udarna vijest',
                                  value: _breakingNews,
                                  onChanged: (v) =>
                                      setState(() => _breakingNews = v),
                                ),
                                _Flag(
                                  label: 'Uživo',
                                  value: _live,
                                  onChanged: (v) => setState(() => _live = v),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Glavna slika',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),

                            // dugme preko cijele širine
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _pickMainPhoto,
                                icon: const Icon(Icons.image),
                                label: Text(
                                  _newMainPhoto != null ||
                                          _existingMainPhotoPath != null
                                      ? 'Promijeni glavnu sliku'
                                      : 'Odaberite glavnu sliku',
                                  textAlign: TextAlign.left,
                                ),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                            // prikaz selektovane slike ispod
                            if (_newMainPhoto != null) ...[
                              const SizedBox(height: 8),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.memory(
                                      _newMainPhoto!.bytes,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() => _newMainPhoto = null);
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (_existingMainPhotoPath != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  _existingMainPhotoPath!,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            Text(
                              'Galerija slika',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _pickGallery,
                                icon: const Icon(Icons.collections),
                                label: const Text('Dodaj slike u galeriju'),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (_existingAdditionalPhotos.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _existingAdditionalPhotos.map((url) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      url,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (_newAdditionalPhotos.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _newAdditionalPhotos.map((p) {
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.memory(
                                          p.bytes,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(
                                              () => _newAdditionalPhotos.remove(
                                                p,
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
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

class _Flag extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Flag({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Text(label),
      ],
    );
  }
}
