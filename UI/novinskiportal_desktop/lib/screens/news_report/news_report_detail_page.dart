import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/widgets/news_report_status_chip.dart';
import 'package:provider/provider.dart';
import '../../models/news_report_models.dart';
import '../../providers/news_report_provider.dart';
import '../../widgets/dialogs/confirm_dialogs.dart';

class NewsReportDetailPage extends StatefulWidget {
  final NewsReportDto report;

  const NewsReportDetailPage({super.key, required this.report});

  @override
  State<NewsReportDetailPage> createState() => _NewsReportDetailPageState();
}

class _NewsReportDetailPageState extends State<NewsReportDetailPage> {
  late final int _reportId;

  NewsReportDto? _report;
  final _adminNote = TextEditingController();

  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _reportId = widget.report.id;
    _report = widget.report;
    _adminNote.text = widget.report.adminNote ?? '';
    _load();
  }

  @override
  void dispose() {
    _adminNote.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final vm = context.read<NewsReportProvider>();

    final detail = await vm.getById(_reportId);

    if (!mounted) return;

    setState(() {
      _report = detail;
      _adminNote.text = detail?.adminNote ?? '';
      _loading = false;
    });
  }

  Future<void> _changeStatus(NewsReportStatus status) async {
    final report = _report;
    if (report == null) return;

    final vm = context.read<NewsReportProvider>();

    final msg = status == NewsReportStatus.approved
        ? 'Jeste li sigurni da želite prihvatiti ovu dojavu?'
        : 'Jeste li sigurni da želite odbiti ovu dojavu?';

    final ok = await showConfirmDialog(context: context, message: msg);

    if (!ok) return;

    setState(() => _updating = true);

    try {
      await vm.changeStatus(
        id: _reportId,
        status: status,
        adminNote: _adminNote.text.trim().isEmpty
            ? null
            : _adminNote.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = _report;
    if (report == null) {
      return const Center(child: Text('Dojava nije pronađena.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detalji dojave', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),

              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dojava br. ${report.id}',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          NewsReportStatusChip(status: report.status),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 32,
                            runSpacing: 8,
                            children: [
                              _InfoRow(
                                label: 'Datum prijave',
                                value: DateFormat(
                                  'd.M.yyyy, HH:mm',
                                ).format(report.createdAt),
                              ),
                              _InfoRow(
                                label: 'Obrađena',
                                value: report.processedAt != null
                                    ? DateFormat(
                                        'd.M.yyyy, HH:mm',
                                      ).format(report.processedAt!)
                                    : '-',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _InfoRow(
                            label: 'Email / korisnik',
                            value:
                                (report.userFullName != null &&
                                    report.userFullName!.trim().isNotEmpty)
                                ? (report.email != null &&
                                          report.email!.trim().isNotEmpty
                                      ? '${report.userFullName!.trim()} (${report.email!.trim()})'
                                      : report.userFullName!.trim())
                                : (report.email != null &&
                                          report.email!.trim().isNotEmpty
                                      ? report.email!.trim()
                                      : '-'),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Tekst dojave',
                            style: theme.textTheme.titleSmall,
                          ),

                          const SizedBox(height: 8),

                          Text(report.text, style: theme.textTheme.bodyMedium),

                          const SizedBox(height: 16),

                          if (report.files.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prilozi',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: report.files.map((f) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: InkWell(
                                        onTap: () => context
                                            .read<NewsReportProvider>()
                                            .openFile(f),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.attach_file,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                f.originalFileName,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),

                          Text(
                            'Admin napomena (nije obavezno)',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _adminNote,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText:
                                  'Unesite napomenu zašto je dojava prihvaćena ili odbijena.',
                            ),
                          ),
                        ],
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
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.12,
                              ),
                              foregroundColor: Colors.red.shade800,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                            ),
                            onPressed: _updating
                                ? null
                                : () =>
                                      _changeStatus(NewsReportStatus.rejected),
                            child: _updating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Odbij'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green.withValues(
                                alpha: .12,
                              ),
                              foregroundColor: Colors.green.shade800,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                            ),

                            onPressed: _updating
                                ? null
                                : () =>
                                      _changeStatus(NewsReportStatus.approved),
                            child: _updating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Prihvati'),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(value),
      ],
    );
  }
}
