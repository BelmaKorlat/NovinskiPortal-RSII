import 'package:flutter/foundation.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/core/notification_service.dart';
import 'package:novinskiportal_mobile/models/favorite/favorite_models.dart';
import 'package:novinskiportal_mobile/services/favorite_service.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider();

  final FavoriteService _service = FavoriteService();

  bool _isLoading = false;
  String? _error;
  final List<FavoriteDto> _items = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FavoriteDto> get items => List.unmodifiable(_items);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _service.get();
      _items
        ..clear()
        ..addAll(list);
    } on ApiException catch (ex) {
      _error = ex.message;
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      _error = 'Došlo je do greške pri učitavanju spremljenih članaka.';
      NotificationService.error('Greška', _error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      NotificationService.error('Greška', ex.message);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Neuspješno spremanje članka.';
      NotificationService.error('Greška', _error!);
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
      notifyListeners();
      return true;
    } on ApiException catch (ex) {
      _error = ex.message;
      NotificationService.error('Greška', ex.message);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Neuspješno uklanjanje članka.';
      NotificationService.error('Greška', _error!);
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleFavorite(int articleId) async {
    if (isFavorite(articleId)) {
      await removeFavorite(articleId);
    } else {
      await createFavorite(articleId);
    }
    return isFavorite(articleId);
  }
}
