import 'package:intl/intl.dart';

String formatRelative(DateTime dt) {
  final now = DateTime.now();
  final local = dt.toLocal();
  final diff = now.difference(local);

  if (diff.inSeconds < 60) {
    return 'Prije par sekundi';
  }

  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return 'Prije $m min';
  }

  if (diff.inHours < 24) {
    final h = diff.inHours;
    return 'Prije $h h';
  }

  if (diff.inDays == 1) {
    return 'Jučer';
  }

  if (diff.inDays < 7) {
    final d = diff.inDays;
    return 'Prije $d dana';
  }

  return DateFormat('d.M.yyyy, HH:mm').format(local);
}
