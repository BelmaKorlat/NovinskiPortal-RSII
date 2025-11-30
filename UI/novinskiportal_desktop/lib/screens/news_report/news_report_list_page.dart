import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/widgets/news_report_status_chip.dart';
import 'package:novinskiportal_desktop/widgets/pagination_bar.dart';
import 'package:provider/provider.dart';
import '../../models/news_report_models.dart';
import '../../providers/news_report_provider.dart';

class NewsReportListPage extends StatefulWidget {
  const NewsReportListPage({super.key});

  @override
  State<NewsReportListPage> createState() => NewsReportListPageState();
}

class NewsReportListPageState extends State<NewsReportListPage> {
  NewsReportStatus _status = NewsReportStatus.pending;

  @override
  void initState() {
    super.initState();
    final vm = context.read<NewsReportProvider>();

    vm.statusFilter ??= NewsReportStatus.pending;

    _status = vm.statusFilter!;

    Future.microtask(() async {
      await vm.load();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFilters() {
    final vm = context.read<NewsReportProvider>();
    vm.page = 0;
    vm.statusFilter = _status;
    vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewsReportProvider>();
    final theme = Theme.of(context);

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
                    'Dojave vijesti',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
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
                child: DropdownButtonFormField<NewsReportStatus?>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: NewsReportStatus.pending,
                      child: Text('Na čekanju'),
                    ),
                    DropdownMenuItem(
                      value: NewsReportStatus.approved,
                      child: Text('Prihvaćene'),
                    ),
                    DropdownMenuItem(
                      value: NewsReportStatus.rejected,
                      child: Text('Odbijene'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _status = v);
                  },
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
          child: vm.isLoading && vm.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.error != null && vm.items.isEmpty
              ? Center(child: Text(vm.error!))
              : _NewsReportTable(
                  items: vm.items,
                  startIndex: vm.page * vm.pageSize,
                  onView: (r) async {
                    Navigator.pushNamed(
                      context,
                      '/news-reports/detail',
                      arguments: r,
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

class _NewsReportTable extends StatelessWidget {
  final List<NewsReportDto> items;
  final int startIndex;
  final void Function(NewsReportDto r) onView;

  const _NewsReportTable({
    required this.items,
    required this.startIndex,
    required this.onView,
  });

  static const double wOrdinal = 90;
  static const double wDate = 170;
  static const double wStatus = 130;
  static const double wActions = 130;

  String _emailOrUser(NewsReportDto r) {
    if (r.email != null && r.email!.trim().isNotEmpty) {
      return r.email!;
    }
    if (r.userFullName != null && r.userFullName!.trim().isNotEmpty) {
      return r.userFullName!;
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (ctx, c) {
          return DataTable2(
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.primary.withValues(alpha: 0.09),
            ),
            minWidth: c.maxWidth,
            columnSpacing: 20,
            headingRowHeight: 44,
            dataRowHeight: 54,
            columns: const [
              DataColumn2(
                label: Center(child: Text('Redni broj')),
                size: ColumnSize.S,
                fixedWidth: wOrdinal,
              ),
              DataColumn2(
                label: Text('Datum prijave'),
                size: ColumnSize.S,
                fixedWidth: wDate,
              ),
              DataColumn2(label: Text('Email / korisnik'), size: ColumnSize.L),
              DataColumn2(
                label: Center(child: Text('Status')),
                size: ColumnSize.S,
                fixedWidth: wStatus,
              ),
              DataColumn2(
                label: Center(child: Text('Akcije')),
                size: ColumnSize.S,
                fixedWidth: wActions,
              ),
            ],
            rows: items.asMap().entries.map((entry) {
              final index = entry.key;
              final r = entry.value;
              final ordinal = startIndex + index + 1;

              return DataRow(
                cells: [
                  DataCell(Center(child: Text('$ordinal'))),
                  DataCell(
                    Text(DateFormat('d.M.yyyy, HH:mm').format(r.createdAt)),
                  ),
                  DataCell(
                    Text(
                      _emailOrUser(r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Center(child: NewsReportStatusChip(status: r.status)),
                  ),
                  DataCell(
                    Center(
                      child: TextButton.icon(
                        onPressed: () => onView(r),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Detalji'),
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
