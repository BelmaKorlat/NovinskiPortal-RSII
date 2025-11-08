import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/models/subcategory_models.dart';
import 'package:novinskiportal_desktop/services/subcategory_service.dart';
import 'package:novinskiportal_desktop/widgets/dialogs/confirm_dialogs.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../models/article_models.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_chip.dart';
import '../../core/api_error.dart';
import '../../core/notification_service.dart';
import '../../models/category_models.dart';
import '../../services/category_service.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});
  @override
  State<ArticleListPage> createState() => ArticleListPageState();
}

class ArticleListPageState extends State<ArticleListPage> {
  bool _categoryLoading = true;
  List<CategoryDto> _categories = [];
  bool _subcategoryLoading = true;
  List<SubcategoryDto> _subcategories = [];
  // vidjeti kako uraditi load user-a
  final _fts = TextEditingController();
  int? _categoryId;
  int? _subcategoryId;
  int? _userId;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ArticleProvider>();
    _fts.text = provider.fts;
    _categoryId = provider.categoryId;
    _subcategoryId = provider.subcategoryId;
    _userId = provider.userId;
    Future.microtask(() => provider.load());

    _loadCategories();
    _loadSubcategories();
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

  Future<void> _loadSubcategories() async {
    try {
      final svc = SubcategoryService();
      final list = await svc.getList(
        const SubcategorySearch(retrieveAll: true, active: true),
      );
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

  @override
  void dispose() {
    _fts.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final vm = context.read<ArticleProvider>();
    vm.page = 0;
    vm.fts = _fts.text.trim();
    vm.categoryId = _categoryId;
    vm.subcategoryId = _subcategoryId;
    vm.userId = _userId;
    vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ArticleProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Članci',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Novi članak'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/articles/new'),
                ),
              ],
            ),
          ),
        ),

        // TOOLBAR
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Flexible(
                flex: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: TextField(
                    controller: _fts,
                    decoration: const InputDecoration(
                      labelText: 'Pretraga po nazivu',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 280,
                child: _categoryLoading
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<int?>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(
                          labelText: 'Filtriraj po kategoriji',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sve kategorije'),
                          ),
                          ..._categories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
              ),
              const SizedBox(width: 12),

              // Potkategorije
              SizedBox(
                width: 280,
                child: _subcategoryLoading
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<int?>(
                        initialValue: _subcategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Filtriraj po potkategoriji',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sve potkategorije'),
                          ),
                          ..._subcategories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _subcategoryId = v),
                      ),
              ),
              const SizedBox(width: 12),
              // Ovako treba uraditi i za usere
              // SizedBox(
              //   width: 280,
              //   child: _subcategoryLoading
              //       ? const LinearProgressIndicator()
              //       : DropdownButtonFormField<int?>(
              //           initialValue: _subcategoryId,
              //           decoration: const InputDecoration(
              //             labelText: 'Filtriraj po potkategoriji',
              //           ),
              //           items: [
              //             const DropdownMenuItem(
              //               value: null,
              //               child: Text('Sve potkategorije'),
              //             ),
              //             ..._subcategories.map(
              //               (c) => DropdownMenuItem(
              //                 value: c.id,
              //                 child: Text(c.name),
              //               ),
              //             ),
              //           ],
              //           onChanged: (v) => setState(() => _subcategoryId = v),
              //         ),
              // ),
              // const SizedBox(width: 12),
              // Traži
              FilledButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search),
                label: const Text('Traži'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // TABLICA
        Expanded(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.error != null
              ? Center(child: Text(vm.error!))
              : _ArticleTable(
                  items: vm.items,
                  onToggle: (id) async {
                    final ok = await showConfirmDialog(
                      context: context,
                      message: 'Jeste li sigurni da želite promijeniti status?',
                    );
                    if (!ok) return;
                    try {
                      await vm.toggle(id);
                    } on ApiException catch (ex) {
                      if (!context.mounted) return;
                      NotificationService.error('Greška', ex.message);
                    } catch (_) {
                      if (!context.mounted) return;
                      NotificationService.error(
                        'Greška',
                        'Greška pri promjeni statusa članka.',
                      );
                    }
                  },
                  onDelete: (id) async {
                    final ok = await showDestructiveConfirmDialog(
                      context: context,
                      message:
                          'Jeste li sigurni da želite obrisati ovaj članak?',
                    );
                    if (!ok) return;
                    try {
                      await vm.remove(id);
                    } on ApiException catch (ex) {
                      if (!context.mounted) return;
                      NotificationService.error('Greška', ex.message);
                    } catch (_) {
                      if (!context.mounted) return;
                      NotificationService.error(
                        'Greška',
                        'Greška pri brisanju članka.',
                      );
                    }
                  },
                  onEdit: (c) {
                    Navigator.pushNamed(
                      context,
                      '/articles/edit',
                      arguments: c,
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: PaginationBar(
              page: vm.page,
              pageSize: vm.pageSize,
              totalCount: vm.totalCount,
              onPageChanged: (p) {
                vm.page = p;
                vm.load();
              },
              onPageSizeChanged: (size) {
                vm.setPageSize(size);
              },
            ),
          ),
        ),
      ],
    );
  }

  //   Future<bool> _confirmDelete(BuildContext context, String msg) async {
  //     final ok = await showDialog<bool>(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (ctx) => AlertDialog(
  //         title: const Text('Potvrda'),
  //         content: Text(msg),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(ctx, false),
  //             child: const Text('Ne'),
  //           ),
  //           FilledButton(
  //             onPressed: () => Navigator.pop(ctx, true),
  //             child: const Text('Da'),
  //           ),
  //         ],
  //       ),
  //     );
  //     return ok == true;
  //   }
}

// Future<bool> _confirmActive(BuildContext context, String msg) async {
//   final ok = await showDialog<bool>(
//     context: context,
//     barrierDismissible: false,
//     builder: (ctx) => AlertDialog(
//       title: const Text('Potvrda'),
//       content: Text(msg),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, false),
//           child: const Text('Ne'),
//         ),
//         FilledButton(
//           onPressed: () => Navigator.pop(ctx, true),
//           child: const Text('Da'),
//         ),
//       ],
//     ),
//   );
//   return ok == true;
// }

// helper za datum
// String _fmtDate(DateTime dt) {
//   return '${dt.day}.${dt.month}.${dt.year}.';
// }

class _ArticleTable extends StatelessWidget {
  final List<ArticleDto> items;
  final void Function(int id) onToggle;
  final void Function(int id) onDelete;
  final void Function(ArticleDto c) onEdit;

  const _ArticleTable({
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  static const double wFlag = 96;
  static const double wActions = 168;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (ctx, c) {
          return DataTable2(
            headingRowColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.09),
            ),
            minWidth: c.maxWidth,

            columnSpacing: 20,
            horizontalMargin: 16,
            headingRowHeight: 44,
            dataRowHeight: 48,

            columns: [
              const DataColumn2(label: Text('Kategorija'), size: ColumnSize.S),
              const DataColumn2(
                label: Text('Potkategorija'),
                size: ColumnSize.S,
              ),
              const DataColumn2(label: Text('Naziv'), size: ColumnSize.L),
              DataColumn2(label: Text('Datum objave'), size: ColumnSize.S),
              DataColumn2(label: Text('Datum kreiranja'), size: ColumnSize.S),
              DataColumn2(label: Text('Autor'), size: ColumnSize.S),
              DataColumn2(
                label: Center(child: Text('Udarna?')),
                size: ColumnSize.S,
                fixedWidth: wFlag,
              ),
              DataColumn2(
                label: Center(child: Text('Uživo?')),
                size: ColumnSize.S,
                fixedWidth: wFlag,
              ),
              DataColumn2(
                label: const Center(child: Text('Aktivna?')),
                size: ColumnSize.S,
                fixedWidth: wFlag,
              ),
              DataColumn2(
                label: const Center(child: Text('Akcije')),
                size: ColumnSize.S,
                fixedWidth: wActions,
              ),
            ],
            rows: items.map((cItem) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      cItem.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.subcategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  //DataCell(Text(_fmtDate(cItem.publishedAt))),
                  DataCell(
                    Text(
                      DateFormat('d.M.yyyy, HH:mm').format(cItem.publishedAt),
                    ),
                  ),
                  DataCell(
                    Text(DateFormat('d.M.yyyy, HH:mm').format(cItem.createdAt)),
                  ),
                  //DataCell(Text(_fmtDate(cItem.createdAt))),
                  DataCell(
                    Text(
                      cItem.user,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Center(child: StatusChip(value: cItem.breakingNews)),
                  ),
                  DataCell(Center(child: StatusChip(value: cItem.live))),
                  DataCell(Center(child: StatusChip(value: cItem.active))),
                  DataCell(
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => onEdit(cItem),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            tooltip: cItem.active ? 'Deaktiviraj' : 'Aktiviraj',
                            onPressed: () => onToggle(cItem.id),
                            icon: Icon(
                              cItem.active ? Icons.toggle_on : Icons.toggle_off,
                              size: 30,
                              color: cItem.active
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          IconButton(
                            onPressed: () => onDelete(cItem.id),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
