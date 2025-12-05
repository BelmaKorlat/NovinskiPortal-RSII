import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/models/article_comment/article_comment_models.dart';
import 'package:novinskiportal_mobile/providers/article_comment/article_comment_provider.dart';
import 'package:provider/provider.dart';

class ArticleCommentReportPage extends StatefulWidget {
  final ArticleCommentResponse comment;

  const ArticleCommentReportPage({super.key, required this.comment});

  @override
  State<ArticleCommentReportPage> createState() =>
      _ArticleCommentReportPageState();
}

class _ArticleCommentReportPageState extends State<ArticleCommentReportPage> {
  final TextEditingController _otherController = TextEditingController();
  String? _selectedReasonKey;
  bool _sending = false;

  static const String _otherKey = 'Drugo';

  final List<String> _reasons = const [
    'Uvredljiv ili vulgaran sadržaj',
    'Govor mržnje ili prijetnje',
    'Spam ili reklama',
    'Off-topic',
    _otherKey,
  ];

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReasonKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Odaberite razlog prijave.')),
      );
      return;
    }

    String finalReason;

    if (_selectedReasonKey == _otherKey) {
      final other = _otherController.text.trim();
      if (other.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upišite razlog prijave u polje ispod.'),
          ),
        );
        return;
      }
      finalReason = 'Drugo: $other';
    } else {
      finalReason = _selectedReasonKey!;
    }

    final provider = context.read<ArticleCommentProvider>();

    setState(() {
      _sending = true;
    });

    final ok = await provider.reportComment(
      commentId: widget.comment.id,
      reason: finalReason,
    );

    if (!mounted) return;

    setState(() {
      _sending = false;
    });

    FocusScope.of(context).unfocus();

    if (!ok) {
      final msg = provider.lastError ?? 'Greška pri prijavi komentara.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prijava komentara je poslana.')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final comment = widget.comment;

    final isOtherSelected = _selectedReasonKey == _otherKey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prijava komentara'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username ?? 'Korisnik',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Odaberite jedan razlog prijave. '
                    'Moderatori će pregledati komentar.',
                  ),
                  const SizedBox(height: 12),

                  RadioGroup<String>(
                    groupValue: _selectedReasonKey,
                    onChanged: (v) {
                      setState(() {
                        _selectedReasonKey = v;
                      });
                    },
                    child: Column(
                      children: _reasons.map((r) {
                        return RadioListTile<String>(
                          value: r,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(r),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (isOtherSelected)
                    TextField(
                      controller: _otherController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Opišite razlog prijave',
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Pošalji prijavu'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
