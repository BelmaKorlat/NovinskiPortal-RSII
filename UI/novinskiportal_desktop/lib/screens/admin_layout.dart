import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  void _onSelect(int i) {
    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/categories');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/subcategories');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/articles');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/users');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/comments');
        break;
      case 6:
        context.read<AuthProvider>().logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/novinskiportal_logo_white_shaded.png'
        : 'assets/novinskiportal_logo_transparent.png';

    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF6A6E77)
        : const Color(0xFFBBBEC2);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 230,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: ListView(
              children: [
                Container(
                  height: 56,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),

                  child: Row(
                    children: [
                      Image.asset(assetPath, height: 40, fit: BoxFit.contain),
                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Novinski Portal',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTextStyle.merge(
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  child: IconTheme.merge(
                    data: const IconThemeData(size: 20),
                    child: Column(
                      children: [
                        _NavTile(
                          icon: Icons.home,
                          label: 'Početna',
                          index: 0,
                          current: widget.currentIndex,
                          onTap: _onSelect,
                        ),
                        _NavTile(
                          icon: Icons.category,
                          label: 'Kategorije',
                          index: 1,
                          current: widget.currentIndex,
                          onTap: _onSelect,
                        ),
                        _NavTile(
                          icon: Icons.list_alt,
                          label: 'Potkategorije',
                          index: 2,
                          current: widget.currentIndex,
                          onTap: _onSelect,
                        ),
                        _NavTile(
                          icon: Icons.article,
                          label: 'Članci',
                          index: 3,
                          current: widget.currentIndex,
                          onTap: _onSelect,
                        ),
                        _NavTile(
                          icon: Icons.people,
                          label: 'Korisnici',
                          index: 4,
                          current: widget.currentIndex,
                          onTap: _onSelect,
                        ),
                        _NavTile(
                          icon: Icons.chat_bubble,
                          label: 'Komentari',
                          index: 5,
                          current: widget.currentIndex,
                          onTap: _onSelect,
                        ),
                        Container(height: 1, color: borderColor),
                        _NavTile(
                          icon: Icons.logout,
                          label: 'Odjava',
                          index: 6,
                          current: widget.currentIndex,
                          onTap: _onSelect,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      const Spacer(),

                      IconButton(
                        tooltip: 'Tema',
                        onPressed: () =>
                            context.read<ThemeProvider>().toggleLightDark(),
                        icon: Icon(
                          context.watch<ThemeProvider>().mode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                      ),
                      const SizedBox(width: 8),

                      Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''} (${user?.username ?? ''})',
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final color = selected ? Theme.of(context).colorScheme.primary : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      selected: selected,
      onTap: () => onTap(index),
    );
  }
}
