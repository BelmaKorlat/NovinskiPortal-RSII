import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuTap;
  final VoidCallback? onSearchTap;
  final IconData actionIcon;

  const MainAppBar({
    super.key,
    required this.title,
    required this.onMenuTap,
    this.onSearchTap,
    this.actionIcon = Icons.search,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
      actions: [
        if (onSearchTap != null)
          IconButton(icon: Icon(actionIcon), onPressed: onSearchTap),
      ],
    );
  }
}
