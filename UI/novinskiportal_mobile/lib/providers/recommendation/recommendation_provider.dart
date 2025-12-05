import 'package:flutter/foundation.dart';
import 'package:novinskiportal_mobile/models/article/article_models.dart';
import 'package:novinskiportal_mobile/services/article_service.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';

class RecommendationProvider extends ChangeNotifier {
  final ArticleService _service = ArticleService();

  bool _isLoading = false;
  String? _error;
  List<ArticleDto> _items = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ArticleDto> get items => List.unmodifiable(_items);

  Future<void> load({int take = 6}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _service.getPersonalized(take: take);
      _items = list;
    } on ApiException catch (e) {
      _error = e.message;
      _items = [];
    } catch (_) {
      _error = 'Došlo je do greške pri učitavanju preporuka.';
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _items = [];
    _error = null;
    notifyListeners();
  }
}
