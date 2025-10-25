// lib/providers/category_provider.dart
import 'package:flutter/foundation.dart';
import '../models/category_models.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final _service = CategoryService();

  bool _loading = false;
  String? _error;
  List<CategoryDto> _items = [];
  // novo
  int _totalCount = 0;

  bool get isLoading => _loading;
  String? get error => _error;
  List<CategoryDto> get items => _items;
  // novo
  int get totalCount => _totalCount;
  int get lastPage => (_totalCount == 0) ? 0 : ((_totalCount - 1) ~/ pageSize);

  // filter state
  bool? active; // null = sve
  String fts = '';
  // novo
  int page = 0;
  int pageSize = 10;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final search = CategorySearch(
        active: active,
        fts: fts.trim().isEmpty ? null : fts.trim(),
        page: page,
        pageSize: pageSize,
        includeTotalCount: true,
      );
      final pr = await _service.getPage(search);
      _items = pr.items;
      _totalCount = pr.totalCount ?? (_items.length + page * pageSize);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // novo
  void nextPage() {
    if (page < lastPage) {
      page++;
      load();
    }
  }

  void prevPage() {
    if (page > 0) {
      page--;
      load();
    }
  }

  void setPageSize(int size) {
    pageSize = size;
    page = 0;
    load();
  }

  Future<void> create(CreateCategoryRequest r) async {
    await _service.create(r);
    await load();
  }

  Future<void> update(int id, UpdateCategoryRequest r) async {
    await _service.update(id, r);
    await load();
  }

  // Hibrid - ako bude radilo ovo dole onda ovo obrisati
  // Future<void> toggle(int id) async {
  //   await _service.toggleStatus(id);
  //   // optimistično osvježi bez reloada:
  //   final i = _items.indexWhere((x) => x.id == id);
  //   if (i != -1) {
  //     final c = _items[i];
  //     _items[i] = CategoryDto(
  //       id: c.id,
  //       name: c.name,
  //       ordinalNumber: c.ordinalNumber,
  //       color: c.color,
  //       active: !c.active,
  //     );
  //     notifyListeners();
  //   }
  // }

  Future<void> toggle(int id) async {
    try {
      final fresh = await _service.toggleStatus(id);
      final i = _items.indexWhere((x) => x.id == id);
      if (i != -1) {
        _items[i] = fresh;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> remove(int id) async {
    await _service.delete(id);
    _items.removeWhere((x) => x.id == id);
    notifyListeners();
  }
}
