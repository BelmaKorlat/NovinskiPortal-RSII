import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:form_validation/form_validation.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../providers/article_provider.dart';
import '../../models/article_models.dart';
import '../../core/notification_service.dart';
import '../../services/category_service.dart';
import '../../models/category_models.dart';
import '../../services/subcategory_service.dart';
import '../../models/subcategory_models.dart';
import '../../providers/auth_provider.dart';

class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({super.key});

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _form = GlobalKey<FormState>();
  final _headline = TextEditingController();
  final _subheadline = TextEditingController();
  final _shortText = TextEditingController();
  late final quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  DateTime _publishedAt = DateTime.now().toLocal();
  bool _publishedAtManuallySet = false;

  bool _active = true;
  bool _hideFullName = false;
  bool _breakingNews = false;
  bool _live = false;

  int? _categoryId;
  int? _subcategoryId;
  bool _categoryLoading = true;
  bool _subcategoryLoading = true;
  List<CategoryDto> _categories = [];
  List<SubcategoryDto> _subcategories = [];

  PhotoUpload? _mainPhoto;
  List<PhotoUpload> _additionalPhotos = [];

  bool _saving = false;

  late final Validator _headlineValidator;
  late final Validator _subheadlineValidator;
  late final Validator _shortTextValidator;

  final _dateTimeFormat = DateFormat('d.M.yyyy. HH:mm');

  @override
  void initState() {
    super.initState();

    _quillController = quill.QuillController.basic();

    _headlineValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 150)],
    );
    _subheadlineValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 200)],
    );
    _shortTextValidator = Validator(
      validators: [RequiredValidator(), MaxLengthValidator(length: 1000)],
    );

    _loadCategories();
    _loadSubcategories();
  }

  @override
  void dispose() {
    _headline.dispose();
    _subheadline.dispose();
    _shortText.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();

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
    setState(() => _mainPhoto = p);
  }

  Future<void> _pickGallery() async {
    final many = await _pickMany();
    if (many.isEmpty) return;
    setState(() => _additionalPhotos = many);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);

    final d = await showDatePicker(
      context: context,
      initialDate: _publishedAt.isBefore(now) ? now : _publishedAt,
      firstDate: today,
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (d == null) return;
    if (!mounted) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
    if (t == null) return;
    if (!mounted) return;

    final selected = DateTime(d.year, d.month, d.day, t.hour, t.minute);

    if (selected.isBefore(now)) {
      NotificationService.error(
        'Greška',
        'Datum i vrijeme objave ne mogu biti u prošlosti.',
      );
      return;
    }

    setState(() {
      _publishedAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      _publishedAtManuallySet = true;
    });
  }

  Future<void> _showMainPhotoPreview() async {
    if (_mainPhoto == null) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Zatvori glavnu sliku',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      pageBuilder: (ctx, _, __) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    heightFactor: 0.8,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.memory(
                        _mainPhoto!.bytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showGalleryPreview(int initialIndex) async {
    if (_additionalPhotos.isEmpty) return;

    int currentIndex = initialIndex;
    final controller = PageController(initialPage: initialIndex);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Zatvori galeriju',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      pageBuilder: (ctx, _, __) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final canGoPrev = currentIndex > 0;
            final canGoNext = currentIndex < _additionalPhotos.length - 1;

            void goTo(int delta) {
              final newIndex = (currentIndex + delta).clamp(
                0,
                _additionalPhotos.length - 1,
              );
              if (newIndex == currentIndex) return;

              controller.animateToPage(
                newIndex,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );

              setStateDialog(() {
                currentIndex = newIndex;
              });
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: controller,
                      itemCount: _additionalPhotos.length,
                      onPageChanged: (i) {
                        setStateDialog(() {
                          currentIndex = i;
                        });
                      },
                      itemBuilder: (ctx, i) {
                        return Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            heightFactor: 0.8,
                            child: InteractiveViewer(
                              panEnabled: false,
                              minScale: 1,
                              maxScale: 4,
                              child: Image.memory(
                                _additionalPhotos[i].bytes,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    Positioned(
                      top: 24,
                      left: 24,
                      child: Text(
                        '${currentIndex + 1} / ${_additionalPhotos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),

                    Positioned(
                      left: 16,
                      child: IconButton(
                        iconSize: 40,
                        onPressed: canGoPrev ? () => goTo(-1) : null,
                        icon: Icon(
                          Icons.chevron_left,
                          color: canGoPrev
                              ? Colors.white
                              : Colors.white.withValues(alpha: .3),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 16,
                      child: IconButton(
                        iconSize: 40,
                        onPressed: canGoNext ? () => goTo(1) : null,
                        icon: Icon(
                          Icons.chevron_right,
                          color: canGoNext
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final now = DateTime.now().toLocal();

    if (!_publishedAtManuallySet) {
      _publishedAt = now;
    } else if (_publishedAt.isBefore(now)) {
      NotificationService.error(
        'Greška',
        'Datum i vrijeme objave ne mogu biti u prošlosti.',
      );
      return;
    }

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

    if (_mainPhoto == null) {
      NotificationService.error('Greška', 'Odaberite glavnu sliku.');
      return;
    }

    final plainText = _quillController.document.toPlainText().trim();
    if (plainText.isEmpty) {
      NotificationService.error('Greška', 'Sadržaj je obavezno polje.');
      return;
    }

    final deltaJson = _quillController.document.toDelta().toJson();

    final ops = List<Map<String, dynamic>>.from(deltaJson);

    final converter = QuillDeltaToHtmlConverter(
      ops,
      ConverterOptions(
        converterOptions: OpConverterOptions(inlineStylesFlag: true),
      ),
    );

    final htmlText = converter.convert();

    setState(() => _saving = true);
    try {
      final req = CreateArticleRequest(
        headline: _headline.text.trim(),
        subheadline: _subheadline.text.trim(),
        shortText: _shortText.text.trim(),
        text: htmlText,
        publishedAt: _publishedAt.toLocal(),
        active: _active,
        hideFullName: _hideFullName,
        breakingNews: _breakingNews,
        live: _live,
        categoryId: _categoryId!,
        subcategoryId: _subcategoryId!,
        userId: userId,
        mainPhoto: _mainPhoto!,
        additionalPhotos: _additionalPhotos,
      );

      await context.read<ArticleProvider>().create(req);
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                'Novi članak',
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
                            Row(
                              children: [
                                Expanded(
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
                                              ? 'Kategorija je obavezno polje.'
                                              : null,
                                        ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: _subcategoryLoading
                                      ? const LinearProgressIndicator()
                                      : DropdownButtonFormField<int>(
                                          initialValue: _subcategoryId,
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
                                              ? 'Potkategorija je obavezno polje.'
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
                            Text(
                              'Sadržaj',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                quill.QuillSimpleToolbar(
                                  controller: _quillController,
                                  config: const quill.QuillSimpleToolbarConfig(
                                    multiRowsDisplay: false,
                                    showFontFamily: false,
                                    showFontSize: true,
                                    showBoldButton: true,
                                    showItalicButton: true,
                                    showUnderLineButton: true,
                                    showStrikeThrough: true,
                                    showListNumbers: true,
                                    showListBullets: true,
                                    showQuote: true,
                                    showCodeBlock: false,
                                    showLink: true,
                                    showInlineCode: false,
                                    showAlignmentButtons: true,
                                    showColorButton: false,
                                    showBackgroundColorButton: false,
                                    showHeaderStyle: true,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: quill.QuillEditor.basic(
                                    controller: _quillController,
                                    config: const quill.QuillEditorConfig(
                                      padding: EdgeInsets.all(8),
                                    ),
                                  ),
                                ),
                              ],
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

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _pickMainPhoto,
                                icon: const Icon(Icons.image),
                                label: Text(
                                  _mainPhoto == null
                                      ? 'Odaberite glavnu sliku'
                                      : 'Promijeni glavnu sliku',
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

                            if (_mainPhoto != null) ...[
                              const SizedBox(height: 8),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  GestureDetector(
                                    onTap: _showMainPhotoPreview,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.memory(
                                        _mainPhoto!.bytes,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() => _mainPhoto = null);
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

                            if (_additionalPhotos.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _additionalPhotos.asMap().entries.map(
                                  (entry) {
                                    final index = entry.key;
                                    final p = entry.value;

                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _showGalleryPreview(index),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Image.memory(
                                              p.bytes,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                setState(
                                                  () => _additionalPhotos
                                                      .remove(p),
                                                );
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ).toList(),
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
