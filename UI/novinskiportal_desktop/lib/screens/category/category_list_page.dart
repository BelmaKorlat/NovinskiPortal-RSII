import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/widgets/dialogs/confirm_dialogs.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_models.dart';
import '../../utils/color_utils.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_chip.dart';
import '../../core/api_error.dart';
import '../../core/notification_service.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});
  @override
  State<CategoryListPage> createState() => CategoryListPageState();
}

class CategoryListPageState extends State<CategoryListPage> {
  final _fts = TextEditingController();
  bool? _active;
  @override
  void initState() {
    super.initState();
    final provider = context.read<CategoryProvider>();
    _fts.text = provider.fts;
    _active = provider.active;
    Future.microtask(() => provider.load());
  }

  @override
  void dispose() {
    _fts.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final vm = context.read<CategoryProvider>();
    vm.page = 0;
    vm.fts = _fts.text.trim();
    vm.active = _active;
    vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoryProvider>();

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
                    'Kategorije',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nova kategorija'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/categories/new'),
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
              : _CategoryTable(
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
                        'Greška pri promjeni statusa kategorije.',
                      );
                    }
                  },
                  onDelete: (id) async {
                    final ok = await showDestructiveConfirmDialog(
                      context: context,
                      message:
                          'Jeste li sigurni da želite obrisati ovu kategoriju?',
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
                        'Greška pri brisanju kategorije.',
                      );
                    }
                  },
                  onEdit: (c) {
                    Navigator.pushNamed(
                      context,
                      '/categories/edit',
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

class _CategoryTable extends StatelessWidget {
  final List<CategoryDto> items;
  final void Function(int id) onToggle;
  final void Function(int id) onDelete;
  final void Function(CategoryDto c) onEdit;

  const _CategoryTable({
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  static const double wOrdinal = 80;
  static const double wColor = 88;
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
            headingRowHeight: 44,
            dataRowHeight: 48,

            columns: [
              DataColumn2(
                label: const Center(child: Text('Redni broj')),
                size: ColumnSize.S,
                fixedWidth: wOrdinal,
              ),
              const DataColumn2(label: Text('Naziv'), size: ColumnSize.L),
              DataColumn2(
                label: const Center(child: Text('Boja')),
                size: ColumnSize.S,
                fixedWidth: wColor,
              ),
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
              return DataRow(
                cells: [
                  DataCell(Center(child: Text('${cItem.ordinalNumber}'))),
                  DataCell(
                    Text(
                      cItem.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(Center(child: _ColorDot(hex: cItem.color))),
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

class _ColorDot extends StatelessWidget {
  final String hex;
  const _ColorDot({required this.hex});

  static const double _size = 16;
  static const bool _showTooltip = true;

  @override
  Widget build(BuildContext context) {
    final col = tryParseHexColor(hex) ?? Theme.of(context).colorScheme.primary;

    final dot = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: col,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
    );

    return _showTooltip ? Tooltip(message: hex, child: dot) : dot;
  }
}
