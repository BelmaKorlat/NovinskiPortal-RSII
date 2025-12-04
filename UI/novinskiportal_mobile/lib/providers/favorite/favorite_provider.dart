import 'package:flutter/foundation.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/models/favorite/favorite_models.dart';
import 'package:novinskiportal_mobile/services/favorite_service.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider();

  final FavoriteService _service = FavoriteService();

  bool _isLoading = false;
  String? _error;
  final List<FavoriteDto> _items = [];

  final int _pageSize = 10;
  int _visibleCount = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FavoriteDto> get items => List.unmodifiable(_items);

  int get visibleCount => _visibleCount;
  bool get hasMore => _visibleCount < _items.length;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _service.get();
      _items
        ..clear()
        ..addAll(list);
      if (_items.isEmpty) {
        _visibleCount = 0;
      } else if (_items.length <= _pageSize) {
        _visibleCount = _items.length;
      } else {
        _visibleCount = _pageSize;
      }
    } on ApiException catch (ex) {
      _error = ex.message;
    } catch (_) {
      _error = 'Došlo je do greške pri učitavanju spremljenih članaka.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (!hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final newCount = _visibleCount + _pageSize;
    _visibleCount = newCount > _items.length ? _items.length : newCount;

    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(int articleId) {
    return _items.any((f) => f.articleId == articleId);
  }

  FavoriteDto? getByArticleId(int articleId) {
    try {
      return _items.firstWhere((f) => f.articleId == articleId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> createFavorite(int articleId) async {
    if (isFavorite(articleId)) return true;

    try {
      final ok = await _service.create(articleId);
      if (!ok) return false;

      await load();
      return true;
    } on ApiException catch (ex) {
      _error = ex.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Neuspješno spremanje članka.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavorite(int articleId) async {
    if (!isFavorite(articleId)) return true;

    try {
      final ok = await _service.remove(articleId);
      if (!ok) return false;

      _items.removeWhere((f) => f.articleId == articleId);
      if (_visibleCount > _items.length) {
        _visibleCount = _items.length;
      }

      notifyListeners();
      return true;
    } on ApiException catch (ex) {
      _error = ex.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Neuspješno uklanjanje članka.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
  }

  Future<bool> toggleFavorite(int articleId) async {
    if (isFavorite(articleId)) {
      final removed = await removeFavorite(articleId);
      return removed;
    }

    final created = await createFavorite(articleId);
    return created;
  }
}
