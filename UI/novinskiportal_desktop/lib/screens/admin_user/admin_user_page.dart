import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/widgets/dialogs/confirm_dialogs.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../models/admin_user_models.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/status_chip.dart';
import 'package:intl/intl.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});
  @override
  State<AdminUserListPage> createState() => AdminUserListPageState();
}

class AdminUserListPageState extends State<AdminUserListPage> {
  final _fts = TextEditingController();
  int? _roleId;
  bool? _active;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminUserProvider>();
    _fts.text = provider.fts;
    _roleId = provider.roleId;
    _active = provider.active;
    Future.microtask(() => provider.load());
  }

  @override
  void dispose() {
    _fts.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final vm = context.read<AdminUserProvider>();
    vm.page = 0;
    vm.fts = _fts.text.trim();
    vm.roleId = _roleId;
    vm.active = _active;
    vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminUserProvider>();

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
                    'Korisnici',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Novi korisnik'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/admin/users/new'),
                ),
              ],
            ),
          ),
        ),

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
                      labelText: 'Pretraga po imenu ili emailu',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              SizedBox(
                width: 180,
                child: DropdownButtonFormField<int?>(
                  initialValue: _roleId,
                  decoration: const InputDecoration(labelText: 'Uloga'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Sve')),
                    DropdownMenuItem(value: 1, child: Text('Admin')),
                    DropdownMenuItem(value: 2, child: Text('Korisnik')),
                  ],
                  onChanged: (v) => setState(() => _roleId = v),
                ),
              ),
              const SizedBox(width: 12),

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
              : _AdminUserTable(
                  items: vm.items,
                  onEdit: (c) {
                    Navigator.pushNamed(
                      context,
                      '/admin/users/edit',
                      arguments: c,
                    );
                  },
                  onToggle: (id) async {
                    final ok = await showConfirmDialog(
                      context: context,
                      message: 'Jeste li sigurni da želite promijeniti status?',
                    );
                    if (!ok) return;
                    await vm.toggle(id);
                  },
                  onSoftDelete: (id) async {
                    final ok = await showDestructiveConfirmDialog(
                      context: context,
                      message: 'Jeste li sigurni da želite obrisati korisnika?',
                    );
                    if (!ok) return;
                    await vm.softDelete(id);
                  },
                  onResetPassword: (c) {
                    Navigator.pushNamed(
                      context,
                      '/admin/users/change-password',
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

class _AdminUserTable extends StatelessWidget {
  final List<UserAdminDto> items;
  final void Function(int id) onToggle;
  final void Function(int id) onSoftDelete;
  final void Function(UserAdminDto c) onEdit;
  final void Function(UserAdminDto c) onResetPassword;

  static const int adminId = 1;

  const _AdminUserTable({
    required this.items,
    required this.onToggle,
    required this.onSoftDelete,
    required this.onEdit,
    required this.onResetPassword,
  });

  static const double wActive = 90;
  static const double wActions = 260;

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
              const DataColumn2(
                label: Text('Ime i prezime'),
                size: ColumnSize.M,
              ),
              const DataColumn2(label: Text('Email'), size: ColumnSize.L),
              const DataColumn2(
                label: Text('Korisničko ime'),
                size: ColumnSize.S,
              ),
              const DataColumn2(label: Text('Nadimak'), size: ColumnSize.S),
              const DataColumn2(label: Text('Uloga'), size: ColumnSize.S),
              const DataColumn2(label: Text('Kreiran'), size: ColumnSize.S),
              const DataColumn2(
                label: Text('Posljednja prijava'),
                size: ColumnSize.S,
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
                  DataCell(
                    Text(
                      '${cItem.firstName} ${cItem.lastName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.nick,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.roleId == adminId ? 'Admin' : 'Korisnik',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(DateFormat('d.M.yyyy, HH:mm').format(cItem.createdAt)),
                  ),
                  DataCell(
                    Text(
                      cItem.lastLoginAt == null
                          ? '-'
                          : DateFormat(
                              'd.M.yyyy, HH:mm',
                            ).format(cItem.lastLoginAt!),
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
                            tooltip: 'Reset lozinke',
                            onPressed: () => onResetPassword(cItem),
                            icon: const Icon(Icons.lock_reset),
                          ),
                          IconButton(
                            tooltip: 'Obriši',
                            onPressed: () => onSoftDelete(cItem.id),
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
