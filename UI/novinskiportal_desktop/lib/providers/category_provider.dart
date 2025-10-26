// lib/providers/category_provider.dart
import '../models/category_models.dart';
import '../services/category_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';

class CategoryProvider extends PagedProvider<CategoryDto, CategorySearch> {
  final _service = CategoryService();

  // filter state
  bool? active; // null = sve
  String fts = '';
  @override
  CategorySearch buildSearch() => CategorySearch(
    active: active,
    fts: fts.trim().isEmpty ? null : fts.trim(),
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
  );

  @override
  Future<PagedResult<CategoryDto>> fetch(CategorySearch s) {
    return _service.getPage(s);
  }

  Future<void> create(CreateCategoryRequest r) async {
    await _service.create(r);
    await load();
  }

  Future<void> update(int id, UpdateCategoryRequest r) async {
    await _service.update(id, r);
    await load();
  }

  Future<void> toggle(int id) async {
    try {
      final fresh = await _service.toggleStatus(id);
      final i = items.indexWhere((x) => x.id == id);
      if (i != -1) {
        items[i] = fresh;
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> remove(int id) async {
    await _service.delete(id);
    items.removeWhere((x) => x.id == id);
    notifyListeners();
  }
}
