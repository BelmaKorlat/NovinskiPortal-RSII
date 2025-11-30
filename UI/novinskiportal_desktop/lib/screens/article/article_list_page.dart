import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/models/admin_user_models.dart';
import 'package:novinskiportal_desktop/models/subcategory_models.dart';
import 'package:novinskiportal_desktop/services/admin_user_service.dart';
import 'package:novinskiportal_desktop/services/subcategory_service.dart';
import 'package:novinskiportal_desktop/widgets/dialogs/confirm_dialogs.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../models/article_models.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_chip.dart';
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
  bool _userLoading = true;
  List<UserAdminDto> _users = [];

  final _fts = TextEditingController();
  int? _categoryId;
  int? _subcategoryId;
  int? _userId;

  final int adminId = 1;

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
    _loadUsers();
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

  Future<void> _loadUsers() async {
    try {
      final svc = AdminUserService();
      final list = await svc.getList(
        const UserAdminSearch(retrieveAll: true, active: true),
      );

      final authors = list.where((u) => u.roleId == adminId).toList();

      authors.sort((a, b) {
        final an = '${a.firstName} ${a.lastName}'.trim().toLowerCase();
        final bn = '${b.firstName} ${b.lastName}'.trim().toLowerCase();
        return an.compareTo(bn);
      });

      setState(() {
        _users = authors;
        _userLoading = false;
      });
    } catch (_) {
      setState(() => _userLoading = false);
      NotificationService.error('Greška', 'Ne mogu učitati autore.');
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

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _fts,
                  decoration: const InputDecoration(
                    labelText: 'Pretraga po nazivu',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 3,
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

              Expanded(
                flex: 3,
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

              Expanded(
                flex: 3,
                child: _userLoading
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<int?>(
                        initialValue: _userId,
                        decoration: const InputDecoration(
                          labelText: 'Filtriraj po autoru',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Svi autori'),
                          ),
                          ..._users.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.firstName} ${c.lastName}'),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _userId = v),
                      ),
              ),

              const SizedBox(width: 12),

              FilledButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search),
                label: const Text('Traži'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

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
                    await vm.toggle(id);
                  },
                  onDelete: (id) async {
                    final ok = await showDestructiveConfirmDialog(
                      context: context,
                      message:
                          'Jeste li sigurni da želite obrisati ovaj članak?',
                    );
                    if (!ok) return;
                    await vm.remove(id);
                  },
                  onEdit: (c) async {
                    final vm = context.read<ArticleProvider>();
                    try {
                      final detail = await vm.getDetail(c.id);
                      if (!context.mounted) return;

                      await Navigator.pushNamed(
                        context,
                        '/articles/edit',
                        arguments: detail,
                      );
                    } catch (_) {}
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
}

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
                  DataCell(
                    Text(
                      DateFormat('d.M.yyyy, HH:mm').format(cItem.publishedAt),
                    ),
                  ),
                  DataCell(
                    Text(DateFormat('d.M.yyyy, HH:mm').format(cItem.createdAt)),
                  ),
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
                            tooltip: 'Uredi',
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
                            tooltip: 'Obriši',
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
