import 'package:flutter/material.dart';
import 'package:novinskiportal_mobile/screens/favorite/favorite_list_page.dart';

class FavoritePageScaffold extends StatefulWidget {
  const FavoritePageScaffold({super.key});

  @override
  State<FavoritePageScaffold> createState() => _FavoritePageScaffoldState();
}

class _FavoritePageScaffoldState extends State<FavoritePageScaffold> {
  final GlobalKey<FavoriteListPageState> _favoritesKey =
      GlobalKey<FavoriteListPageState>();

  bool _selectionMode = false;

  void _startSelectionMode() {
    setState(() {
      _selectionMode = true;
    });
    _favoritesKey.currentState?.enterSelectionMode();
  }

  void _cancelSelectionMode() {
    setState(() {
      _selectionMode = false;
    });
    _favoritesKey.currentState?.cancelSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_selectionMode ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (_selectionMode) {
              _cancelSelectionMode();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _selectionMode ? 'Odaberite' : 'Spremljeni članci',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        actions: [
          if (!_selectionMode)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _startSelectionMode();
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'delete', child: Text('Brisanje')),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: FavoriteListPage(
          key: _favoritesKey,
          onDeleteCompleted: () {
            setState(() {
              _selectionMode = false;
            });
          },
        ),
      ),
    );
  }
}
