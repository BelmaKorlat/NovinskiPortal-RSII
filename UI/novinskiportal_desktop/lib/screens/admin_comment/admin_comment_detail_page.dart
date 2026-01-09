import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/providers/admin_comment_provider.dart';
import 'package:novinskiportal_desktop/widgets/comment_status_chip.dart';
import 'package:provider/provider.dart';

import 'package:novinskiportal_desktop/models/admin_comment_models.dart';
import 'package:novinskiportal_desktop/providers/admin_comment_detail_provider.dart';

class AdminCommentDetailPage extends StatefulWidget {
  const AdminCommentDetailPage({super.key});

  @override
  State<AdminCommentDetailPage> createState() => _AdminCommentDetailPageState();
}

class _AdminCommentDetailPageState extends State<AdminCommentDetailPage> {
  bool _inited = false;
  int? _commentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args is int) {
      _commentId = args;
    } else if (args is AdminCommentReportResponse) {
      _commentId = args.id;
    }

    if (_commentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final vm = context.read<AdminCommentDetailProvider>();
        vm.load(_commentId!);
      });
    }

    _inited = true;
  }

  Future<String?> _askAdminNote() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Odbij prijave'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Napomena admina (opcionalno)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Otkaži'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx, controller.text.trim());
            },
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Future<void> _rejectPendingReports(AdminCommentDetailReportResponse d) async {
    if (_commentId == null) return;

    if (d.pendingReportsCount == 0) return;

    final note = await _askAdminNote();
    if (note == null) return;
    if (!mounted) return;
    final listVm = context.read<AdminCommentProvider>();
    final detailVm = context.read<AdminCommentDetailProvider>();

    await listVm.rejectPendingReports(
      _commentId!,
      adminNote: note.isEmpty ? null : note,
    );

    await detailVm.load(_commentId!);
  }

  Future<BanCommentAuthorRequest?> _askBanAuthor() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (!mounted || pickedDate == null) return null;

    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zabrani komentarisanje'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Razlog zabrane (opcionalno)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Otkaži'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx, reasonController.text.trim());
            },
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    reasonController.dispose();

    if (reason == null) {
      return null;
    }

    final banUntilLocal = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      23,
      59,
    );

    return BanCommentAuthorRequest(
      banUntil: banUntilLocal,
      reason: reason.isEmpty ? null : reason,
    );
  }

  Future<void> _banAuthor(AdminCommentDetailReportResponse d) async {
    if (_commentId == null) return;

    final now = DateTime.now();
    if (d.authorCommentBanUntil != null &&
        d.authorCommentBanUntil!.isAfter(now)) {
      return;
    }

    final req = await _askBanAuthor();
    if (req == null) return;
    if (!mounted) return;
    final listVm = context.read<AdminCommentProvider>();
    final detailVm = context.read<AdminCommentDetailProvider>();

    await listVm.banAuthor(_commentId!, req);
    await detailVm.load(_commentId!);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminCommentDetailProvider>();
    final cs = Theme.of(context).colorScheme;

    Widget body;

    if (_commentId == null) {
      body = const Center(child: Text('Komentar nije pronađen.'));
    } else if (vm.isLoading && vm.detail == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null) {
      body = Center(child: Text(vm.error!));
    } else if (vm.detail == null) {
      body = const Center(child: Text('Detalji komentara nisu dostupni.'));
    } else {
      final d = vm.detail!;
      final banText = _banText(d);

      body = Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalji komentara',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),

                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
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
                            const Expanded(child: Text('Osnovne informacije')),
                            CommentStatusChip.fromDetail(detail: d),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              label: 'Članak',
                              value:
                                  '${d.articleHeadline} (ID: ${d.articleId})',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Autor komentara',
                              value:
                                  '${d.commentAuthorUsername} (ID: ${d.commentAuthorId})',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Kreiran',
                              value: DateFormat(
                                'd.M.yyyy, HH:mm',
                              ).format(d.commentCreatedAt),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Prijave',
                              value:
                                  '${d.reportsCount} (${d.pendingReportsCount} na čekanju)',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Prva prijava',
                              value: d.firstReportedAt == null
                                  ? '-'
                                  : DateFormat(
                                      'd.M.yyyy, HH:mm',
                                    ).format(d.firstReportedAt!),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Zadnja prijava',
                              value: d.lastReportedAt == null
                                  ? '-'
                                  : DateFormat(
                                      'd.M.yyyy, HH:mm',
                                    ).format(d.lastReportedAt!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: cs.outlineVariant),
                          ),
                        ),
                        child: const Text('Sadržaj komentara'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: cs.outlineVariant),
                            color: cs.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: Text(
                            d.content,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (banText != null) ...[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: cs.outlineVariant),
                            ),
                          ),
                          child: const Text('Zabrana komentarisanja'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            banText,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: d.pendingReportsCount == 0
                            ? null
                            : () => _rejectPendingReports(d),
                        icon: const Icon(Icons.gavel_outlined),
                        label: Text(
                          'Odbij sve prijave (${d.pendingReportsCount})',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed:
                            d.authorCommentBanUntil != null &&
                                d.authorCommentBanUntil!.isAfter(DateTime.now())
                            ? null
                            : () => _banAuthor(d),
                        icon: const Icon(Icons.person_off),
                        label: const Text('Zabrani komentarisanje'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: cs.outlineVariant),
                          ),
                        ),
                        child: Text(
                          d.reports.isEmpty
                              ? 'Prijave na komentar'
                              : 'Prijave na komentar (${d.reports.length})',
                        ),
                      ),
                      if (d.reports.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nema prijava za ovaj komentar.'),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: d.reports.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: cs.outlineVariant),
                          itemBuilder: (ctx, index) {
                            final r = d.reports[index];
                            final createdText = DateFormat(
                              'd.M.yyyy, HH:mm',
                            ).format(r.createdAt);
                            final processedText = r.processedAt == null
                                ? '-'
                                : DateFormat(
                                    'd.M.yyyy, HH:mm',
                                  ).format(r.processedAt!);

                            final status = _reportStatusText(r.status);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Prijavio: ${r.reporterUsername}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        createdText,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: $status',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Razlog prijave:',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    r.reason,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  _InfoRow(
                                    label: 'Obradio admin',
                                    value: r.processedByAdminUsername ?? '-',
                                    small: true,
                                  ),
                                  _InfoRow(
                                    label: 'Obrađeno',
                                    value: processedText,
                                    small: true,
                                  ),
                                  if (r.adminNote != null &&
                                      r.adminNote!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Napomena admina:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      r.adminNote!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
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

    return Padding(padding: const EdgeInsets.all(16), child: body);
  }

  String? _banText(AdminCommentDetailReportResponse d) {
    final hasReason =
        d.authorCommentBanReason != null &&
        d.authorCommentBanReason!.trim().isNotEmpty;
    final hasUntil = d.authorCommentBanUntil != null;

    if (!hasReason && !hasUntil) return null;

    final untilStr = hasUntil
        ? DateFormat('d.M.yyyy, HH:mm').format(d.authorCommentBanUntil!)
        : null;

    if (untilStr != null && hasReason) {
      return 'Autor ima zabranu komentarisanja do $untilStr. Razlog: ${d.authorCommentBanReason}.';
    }

    if (untilStr != null) {
      return 'Autor ima zabranu komentarisanja do $untilStr.';
    }

    return 'Zabrana komentarisanja: ${d.authorCommentBanReason}.';
  }

  String _reportStatusText(ArticleCommentReportStatus status) {
    switch (status) {
      case ArticleCommentReportStatus.pending:
        return 'Na čekanju';
      case ArticleCommentReportStatus.approved:
        return 'Prihvaćena';
      case ArticleCommentReportStatus.rejected:
        return 'Odbijena';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool small;

  const _InfoRow({
    required this.label,
    required this.value,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final styleLabel = small
        ? Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
        : Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    final styleValue = small
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 170, child: Text(label, style: styleLabel)),
        Expanded(child: Text(value, style: styleValue)),
      ],
    );
  }
}
