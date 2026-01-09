import 'package:flutter/material.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  String title = 'Potvrda',
  required String message,
  String cancelLabel = 'Ne',
  String confirmLabel = 'Da',
}) async {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actionsAlignment: MainAxisAlignment.end,

      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),

      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            cancelLabel,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return ok ?? false;
}

Future<bool> showDestructiveConfirmDialog({
  required BuildContext context,
  String title = 'Potvrda brisanja',
  required String message,
  String subMessage = 'Ova radnja je trajna i ne može se poništiti.',
  String cancelLabel = 'Otkaži',
  String confirmLabel = 'Obriši',
}) async {
  final cs = Theme.of(context).colorScheme;

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),

      title: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (subMessage.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),

      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.delete_outline, size: 16),
          label: Text(confirmLabel),
        ),
      ],
    ),
  );

  return ok ?? false;
}
