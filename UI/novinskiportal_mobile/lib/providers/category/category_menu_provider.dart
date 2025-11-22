import 'package:flutter/material.dart';
import '../../models/category/category_menu_models.dart';
import '../../services/category_service.dart';
import '../../core/api_error.dart';

class CategoryMenuProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  CategoryMenuProvider();

  List<CategoryMenuDto> _items = [];
  bool _loading = false;
  String? _error;

  List<CategoryMenuDto> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _service.getMenu();
    } on ApiException catch (ex) {
      _error = ex.message;
    } catch (_) {
      _error = 'Neočekivana greška.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void toggleExpanded(int categoryId) {
    final index = _items.indexWhere((c) => c.id == categoryId);
    if (index == -1) return;

    _items[index].isExpanded = !_items[index].isExpanded;
    notifyListeners();
  }
}
