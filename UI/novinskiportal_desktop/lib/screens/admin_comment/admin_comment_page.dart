import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/widgets/dialogs/confirm_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:novinskiportal_desktop/models/admin_comment_models.dart';
import 'package:novinskiportal_desktop/providers/admin_comment_provider.dart';
import 'package:novinskiportal_desktop/widgets/pagination_bar.dart';

class AdminCommentListPage extends StatefulWidget {
  const AdminCommentListPage({super.key});

  @override
  State<AdminCommentListPage> createState() => AdminCommentListPageState();
}

class AdminCommentListPageState extends State<AdminCommentListPage> {
  ArticleCommentReportStatus? _status;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AdminCommentProvider>();

    _status = vm.status;

    Future.microtask(() => vm.load());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFilters() {
    final vm = context.read<AdminCommentProvider>();

    vm.page = 0;
    vm.status = _status;
    vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminCommentProvider>();

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
                    'Prijavljeni komentari',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<ArticleCommentReportStatus?>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status prijave',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Sve')),
                    DropdownMenuItem(
                      value: ArticleCommentReportStatus.pending,
                      child: Text('Samo pending'),
                    ),
                    DropdownMenuItem(
                      value: ArticleCommentReportStatus.approved,
                      child: Text('Samo odobrene'),
                    ),
                    DropdownMenuItem(
                      value: ArticleCommentReportStatus.rejected,
                      child: Text('Samo odbijene'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v),
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
              : _AdminCommentTable(items: vm.items),
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

class _AdminCommentTable extends StatelessWidget {
  final List<AdminCommentReportResponse> items;

  const _AdminCommentTable({required this.items});

  static const double _wActions = 200;

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
            dataRowHeight: 60,
            columns: const [
              DataColumn2(label: Text('Članak'), size: ColumnSize.M),
              DataColumn2(label: Text('Autor'), size: ColumnSize.S),
              DataColumn2(label: Text('Komentar'), size: ColumnSize.L),
              DataColumn2(label: Text('Prijave'), size: ColumnSize.S),
              DataColumn2(label: Text('Prva prijava'), size: ColumnSize.S),
              DataColumn2(label: Text('Zadnja prijava'), size: ColumnSize.S),
              DataColumn2(label: Text('Status'), size: ColumnSize.S),
              DataColumn2(
                label: Center(child: Text('Akcije')),
                size: ColumnSize.S,
                fixedWidth: _wActions,
              ),
            ],
            rows: items.map((cItem) {
              final statusText = _buildStatusText(cItem);

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      cItem.articleHeadline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.commentAuthorUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      '${cItem.reportsCount} (${cItem.pendingReportsCount} pending)',
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.firstReportedAt == null
                          ? '-'
                          : DateFormat(
                              'd.M.yyyy, HH:mm',
                            ).format(cItem.firstReportedAt!),
                    ),
                  ),
                  DataCell(
                    Text(
                      cItem.lastReportedAt == null
                          ? '-'
                          : DateFormat(
                              'd.M.yyyy, HH:mm',
                            ).format(cItem.lastReportedAt!),
                    ),
                  ),
                  DataCell(Text(statusText)),
                  DataCell(
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Detalji',
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/comments/detail',
                                arguments: cItem.id,
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Sakrij komentar',
                            icon: const Icon(Icons.visibility_off),
                            onPressed: () async {
                              final vm = context.read<AdminCommentProvider>();

                              final ok = await showConfirmDialog(
                                context: context,
                                message:
                                    'Jeste li sigurni da želite sakriti komentar i odobriti pending prijave?',
                                confirmLabel: 'Sakrij',
                                cancelLabel: 'Odustani',
                              );
                              if (!ok) return;

                              await vm.hide(cItem.id);
                            },
                          ),
                          IconButton(
                            tooltip: 'Obriši komentar',
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final vm = context.read<AdminCommentProvider>();

                              final ok = await showDestructiveConfirmDialog(
                                context: context,
                                message:
                                    'Jeste li sigurni da želite obrisati komentar?',
                                subMessage:
                                    'Komentar će biti obrisan i sakriven, pending prijave će biti odobrene.',
                                confirmLabel: 'Obriši',
                                cancelLabel: 'Odustani',
                              );
                              if (!ok) return;

                              await vm.softDelete(cItem.id);
                            },
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

  static String _buildStatusText(AdminCommentReportResponse c) {
    if (c.isDeleted) return 'Obrisan';
    if (c.isHidden) return 'Sakriven';
    return 'Vidljiv';
  }
}
