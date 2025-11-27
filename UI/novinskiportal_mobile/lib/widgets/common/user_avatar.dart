import 'package:flutter/material.dart';

// class UserAvatar extends StatelessWidget {
//   final String username;
//   final double radius;

//   const UserAvatar({super.key, required this.username, this.radius = 16});

//   static const List<Color> _avatarColors = [
//     // Colors.red,
//     // Colors.blue,
//     // Colors.green,
//     // Colors.orange,
//     // Colors.purple,
//     // Colors.teal,
//     // Colors.brown,
//     // Colors.indigo,
//     Color(0xFFEF5350), // red 400
//     Color(0xFFEC407A), // pink 400
//     Color(0xFFAB47BC), // purple 400
//     Color(0xFF7E57C2), // deep purple 400
//     Color(0xFF5C6BC0), // indigo 400
//     Color(0xFF42A5F5), // blue 400
//     Color(0xFF26C6DA), // cyan 400
//     Color(0xFF26A69A), // teal 400
//     Color(0xFF66BB6A), // green 400
//     Color(0xFFFFCA28), // amber 400
//     Color(0xFFFFA726), // orange 400
//     Color(0xFF8D6E63), // brown 400
//   ];

//   Color _colorFor(String text) {
//     if (text.isEmpty) {
//       return _avatarColors.first;
//     }

//     var hash = 0;
//     for (final codeUnit in text.codeUnits) {
//       hash = (hash + codeUnit) & 0x7fffffff;
//     }

//     final index = hash % _avatarColors.length;
//     return _avatarColors[index];
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   final theme = Theme.of(context);

//   //   final trimmed = username.trim();
//   //   final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

//   //   final bgColor = _colorFor(username);

//   //   return CircleAvatar(
//   //     radius: radius,
//   //     backgroundColor: bgColor,
//   //     child: Text(
//   //       initial,
//   //       style: theme.textTheme.labelMedium?.copyWith(
//   //         color: Colors.white,
//   //         fontWeight: FontWeight.w600,
//   //       ),
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final cs = theme.colorScheme;

//     final trimmed = username.trim();
//     final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

//     final bgColor = _colorFor(username);

//     final double size = radius * 2;

//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: bgColor,
//         border: Border.all(color: cs.surface, width: 2),
//         boxShadow: [
//           BoxShadow(
//             color: cs.shadow.withValues(alpha: 0.10),
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           initial,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//       ),
//     );
//   }
// }
class UserAvatar extends StatelessWidget {
  final String username;
  final double radius;

  const UserAvatar({super.key, required this.username, this.radius = 16});

  // srednje boje kao što smo već stavili
  static const List<Color> _avatarColors = [
    Color(0xFFEF5350), // red 400
    Color(0xFFEC407A), // pink 400
    Color(0xFFAB47BC), // purple 400
    Color(0xFF7E57C2), // deep purple 400
    Color(0xFF5C6BC0), // indigo 400
    Color(0xFF42A5F5), // blue 400
    Color(0xFF26C6DA), // cyan 400
    Color(0xFF26A69A), // teal 400
    Color(0xFF66BB6A), // green 400
    Color(0xFFFFCA28), // amber 400
    Color(0xFFFFA726), // orange 400
    Color(0xFF8D6E63), // brown 400
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

    // ako ima razmake, uzmi prvo slovo prve i zadnje riječi
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts.first;
      final last = parts.last;
      return (first[0] + last[0]).toUpperCase();
    }

    // ako nema razmaka, uzmi prva dva karaktera ako postoje
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
        color: cs.surfaceVariant, // nježna, neutralna pozadina
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
