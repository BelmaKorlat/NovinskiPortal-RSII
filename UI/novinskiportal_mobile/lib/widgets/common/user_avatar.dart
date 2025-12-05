import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String username;
  final double radius;

  const UserAvatar({super.key, required this.username, this.radius = 16});

  static const List<Color> _avatarColors = [
    Color(0xFFEF5350),
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
    Color(0xFF7E57C2),
    Color(0xFF5C6BC0),
    Color(0xFF42A5F5),
    Color(0xFF26C6DA),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFFFA726),
    Color(0xFF8D6E63),
  ];

  Color _colorFor(String text) {
    if (text.isEmpty) {
      return _avatarColors.first;
    }

    var hash = 0;
    for (final codeUnit in text.codeUnits) {
      hash = (hash + codeUnit) & 0x7fffffff;
    }

    final index = hash % _avatarColors.length;
    return _avatarColors[index];
  }

  String _initialsFor(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts.first;
      final last = parts.last;
      return (first[0] + last[0]).toUpperCase();
    }

    if (trimmed.length >= 2) {
      return (trimmed[0] + trimmed[1]).toUpperCase();
    }

    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final initials = _initialsFor(username);
    final accentColor = _colorFor(username);
    final double size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.surface,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.10),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
