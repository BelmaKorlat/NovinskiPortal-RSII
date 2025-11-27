import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/models/article_comment/article_comment_models.dart';
import 'package:novinskiportal_mobile/providers/article_comment/article_comment_provider.dart';
import 'package:novinskiportal_mobile/utils/datetime_utils.dart';
import 'package:novinskiportal_mobile/widgets/common/user_avatar.dart';
import 'package:provider/provider.dart';

class ArticleCommentListPage extends StatefulWidget {
  final int articleId;
  final String headline;
  final Color categoryColor;

  const ArticleCommentListPage({
    super.key,
    required this.articleId,
    required this.headline,
    required this.categoryColor,
  });

  @override
  State<ArticleCommentListPage> createState() => _ArticleCommentListPageState();
}

class _ArticleCommentListPageState extends State<ArticleCommentListPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _commentController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _commentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ArticleCommentProvider>();
      provider.loadInitial(widget.articleId);
    });
  }

  void _onScroll() {
    final provider = context.read<ArticleCommentProvider>();

    if (!_scrollController.hasClients) return;

    if (!provider.hasMore || provider.isLoading) return;

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= max - 300) {
      provider.loadMore();
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _sending) return;

    final provider = context.read<ArticleCommentProvider>();

    setState(() {
      _sending = true;
    });

    final ok = await provider.create(content: text, parentCommentId: null);

    if (!mounted) return;

    setState(() {
      _sending = false;
    });

    if (ok) {
      _commentController.clear();

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else {
      final msg =
          provider.lastError ?? 'Greška pri slanju komentara. Pokušaj ponovo.';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildNote(ThemeData theme, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'NAPOMENA: Komentarisanje je omogućeno samo prijavljenim korisnicima. '
              'Piši pristojno, bez vrijeđanja i vulgarnog sadržaja. '
              'Komentari sa govorom mržnje mogu dovesti do sankcija.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleCommentProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Komentari',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: widget.categoryColor.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Komentari za',
                  style: theme.textTheme.labelSmall?.copyWith(),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Builder(
              builder: (_) {
                if (provider.isLoading && provider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.error!,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () =>
                                provider.loadInitial(widget.articleId),
                            child: const Text('Pokušaj ponovo'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadInitial(widget.articleId),
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildNote(theme, cs),
                      if (provider.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Još nema komentara.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      else
                        ..._buildCommentList(provider, theme),
                      if (provider.hasMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Ostavite komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sending ? null : _sendComment,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    color: cs.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCommentList(
    ArticleCommentProvider provider,
    ThemeData theme,
  ) {
    final widgets = <Widget>[];

    for (final c in provider.items) {
      widgets.add(_CommentTile(comment: c));
    }

    return widgets;
  }
}

Future<void> _showReportDialog(
  BuildContext context,
  ArticleCommentResponse comment,
) async {
  final provider = context.read<ArticleCommentProvider>();
  final otherController = TextEditingController();

  // ponuđeni razlozi
  const otherKey = 'Drugo';
  final reasons = <String>[
    'Uvredljiv ili vulgaran sadržaj',
    'Govor mržnje ili prijetnje',
    'Spam ili reklama',
    'Off-topic',
    otherKey,
  ];

  String? selectedReasonKey;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final isOtherSelected = selectedReasonKey == otherKey;

          return AlertDialog(
            title: const Text('Prijava komentara'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Odaberi jedan razlog prijave. '
                    'Moderatori će pregledati komentar.',
                  ),
                  const SizedBox(height: 12),

                  // radio dugmad, samo jedan se može izabrati
                  ...reasons.map((r) {
                    return RadioListTile<String>(
                      value: r,
                      groupValue: selectedReasonKey,
                      onChanged: (v) {
                        setState(() {
                          selectedReasonKey = v;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(r),
                    );
                  }),

                  const SizedBox(height: 8),

                  if (isOtherSelected) ...[
                    TextField(
                      controller: otherController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Opiši razlog prijave',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Odustani'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedReasonKey == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Odaberi razlog prijave.')),
                    );
                    return;
                  }

                  String finalReason;

                  if (selectedReasonKey == otherKey) {
                    final other = otherController.text.trim();
                    if (other.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Upiši razlog prijave u polje ispod.'),
                        ),
                      );
                      return;
                    }
                    finalReason = 'Drugo: $other';
                  } else {
                    finalReason = selectedReasonKey!;
                  }

                  final ok = await provider.reportComment(
                    commentId: comment.id,
                    reason: finalReason,
                  );

                  if (!ctx.mounted) return;

                  if (!ok) {
                    final msg =
                        provider.lastError ?? 'Greška pri prijavi komentara.';
                    ScaffoldMessenger.of(
                      ctx,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                    return;
                  }

                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prijava komentara je poslana.'),
                    ),
                  );
                },
                child: const Text('Pošalji prijavu'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _CommentTile extends StatelessWidget {
  final ArticleCommentResponse comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final provider = context.read<ArticleCommentProvider>();
    final isLiked = comment.userVote == 1;
    final isDisliked = comment.userVote == -1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    username: comment.username ?? 'Korisnik',
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment.username ?? 'Korisnik',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatRelative(comment.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (comment.isOwner) ...[
                    const SizedBox(width: 6),
                    Text(
                      ' · Vi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.primary,
                      ),
                    ),
                  ],
                  // novo
                  if (!comment.isOwner) ...[
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      onSelected: (value) {
                        if (value == 'report') {
                          _showReportDialog(context, comment);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Prijavi komentar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(comment.content, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      provider.voteOnComment(commentId: comment.id, value: 1);
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          size: 18,
                          color: isLiked
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likesCount.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLiked
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      provider.voteOnComment(commentId: comment.id, value: -1);
                    },
                    child: Row(
                      children: [
                        Icon(
                          isDisliked
                              ? Icons.thumb_down
                              : Icons.thumb_down_alt_outlined,
                          size: 18,
                          color: isDisliked
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.dislikesCount.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDisliked
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
