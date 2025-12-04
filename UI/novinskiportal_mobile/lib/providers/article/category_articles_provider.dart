import 'package:flutter/foundation.dart';
import '../../models/category/category_articles_models.dart';
import '../../services/article_service.dart';
import '../../core/api_error.dart';

class CategoryArticlesProvider extends ChangeNotifier {
  final ArticleService _service = ArticleService();

  bool _loading = false;
  String? _error;
  List<CategoryArticlesDto> _items = [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<CategoryArticlesDto> get items => _items;

  Future<void> load({int perCategory = 5}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _service.getCategoryArticles(perCategory: perCategory);
      _items = list;
    } on ApiException catch (ex) {
      _items = [];
      _error = ex.message;
    } catch (_) {
      _items = [];
      _error = 'Došlo je do greške pri učitavanju vijesti.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({int perCategory = 5}) => load(perCategory: perCategory);
}
