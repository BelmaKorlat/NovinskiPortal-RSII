// import 'package:flutter/material.dart';
// import 'package:novinskiportal_desktop/models/admin_comment_models.dart';

// class CommentStatusChip extends StatelessWidget {
//   final AdminCommentReportResponse comment;

//   const CommentStatusChip({super.key, required this.comment});

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     String text;
//     Color bg;
//     Color fg;

//     if (comment.isDeleted) {
//       text = 'Obrisan';
//       bg = cs.error.withValues(alpha: 0.12);
//       fg = cs.error;
//     } else if (comment.isHidden) {
//       text = 'Sakriven';
//       bg = cs.tertiary.withValues(alpha: 0.12);
//       fg = cs.tertiary;
//     } else {
//       text = 'Vidljiv';
//       bg = cs.primary.withValues(alpha: 0.12);
//       fg = cs.primary;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: fg, fontWeight: FontWeight.w600),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/models/admin_comment_models.dart';

class CommentStatusChip extends StatelessWidget {
  final bool isDeleted;
  final bool isHidden;

  CommentStatusChip({super.key, required AdminCommentReportResponse comment})
    : isDeleted = comment.isDeleted,
      isHidden = comment.isHidden;

  CommentStatusChip.fromDetail({
    super.key,
    required AdminCommentDetailReportResponse detail,
  }) : isDeleted = detail.isDeleted,
       isHidden = detail.isHidden;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String text;
    Color bg;
    Color fg;

    if (isDeleted) {
      text = 'Obrisan';
      bg = cs.error.withValues(alpha: 0.12);
      fg = cs.error;
    } else if (isHidden) {
      text = 'Sakriven';
      bg = cs.tertiary.withValues(alpha: 0.12);
      fg = cs.tertiary;
    } else {
      text = 'Vidljiv';
      bg = cs.primary.withValues(alpha: 0.12);
      fg = cs.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
