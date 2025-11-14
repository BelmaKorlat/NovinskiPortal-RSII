import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/widgets/dialogs/confirm_dialogs.dart';
import 'package:provider/provider.dart';
import '../../providers/subcategory_provider.dart';
import '../../models/subcategory_models.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_chip.dart';
import '../../core/api_error.dart';
import '../../core/notification_service.dart';
import '../../models/category_models.dart';
import '../../services/category_service.dart';

class SubcategoryListPage extends StatefulWidget {
  const SubcategoryListPage({super.key});
  @override
  State<SubcategoryListPage> createState() => SubcategoryListPageState();
}

class SubcategoryListPageState extends State<SubcategoryListPage> {
  bool _categoryLoading = true;
  List<CategoryDto> _categories = [];
  int? _categoryId;
  bool? _active;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SubcategoryProvider>();
    _categoryId = provider.categoryId;
    _active = provider.active;
    Future.microtask(() => provider.load());

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

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFilters() {
    final vm = context.read<SubcategoryProvider>();
    vm.page = 0;
    vm.categoryId = _categoryId;
    vm.active = _active;
    vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubcategoryProvider>();

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
                    'Potkategorije',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nova potkategorija'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/subcategories/new'),
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

              // Status
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<bool?>(
                  initialValue: _active,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Sve')),
                    DropdownMenuItem(value: true, child: Text('Aktivne')),
                    DropdownMenuItem(value: false, child: Text('Neaktivne')),
                  ],
                  onChanged: (v) => setState(() => _active = v),
                ),
              ),
              const SizedBox(width: 12),

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
              : _SubcategoryTable(
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
                        'Greška pri promjeni statusa potkategorije.',
                      );
                    }
                  },
                  onDelete: (id) async {
                    final ok = await showDestructiveConfirmDialog(
                      context: context,
                      message:
                          'Jeste li sigurni da želite obrisati ovu potkategoriju?',
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
                        'Greška pri brisanju potkategorije.',
                      );
                    }
                  },
                  onEdit: (c) {
                    Navigator.pushNamed(
                      context,
                      '/subcategories/edit',
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
}

class _SubcategoryTable extends StatelessWidget {
  final List<SubcategoryDto> items;
  final void Function(int id) onToggle;
  final void Function(int id) onDelete;
  final void Function(SubcategoryDto c) onEdit;

  const _SubcategoryTable({
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  static const double wOrdinal = 90;
  static const double wActive = 96;
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
              DataColumn2(
                label: const Center(child: Text('Redni broj')),
                size: ColumnSize.S,
                fixedWidth: wOrdinal,
              ),
              const DataColumn2(label: Text('Naziv'), size: ColumnSize.L),

              DataColumn2(
                label: const Center(child: Text('Aktivna?')),
                size: ColumnSize.S,
                fixedWidth: wActive,
              ),
              DataColumn2(
                label: const Center(child: Text('Akcije')),
                size: ColumnSize.S,
                fixedWidth: wActions,
              ),
            ],
            rows: items.map((cItem) {
              final categoryName = cItem.categoryName ?? '${cItem.categoryId}';
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(Center(child: Text('${cItem.ordinalNumber}'))),
                  DataCell(
                    Text(
                      cItem.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
