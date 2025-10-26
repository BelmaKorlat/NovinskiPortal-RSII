// lib/providers/paged_provider.dart
import 'package:flutter/foundation.dart';
import '../core/paging.dart';

abstract class PagedProvider<T, S> extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<T> _items = [];
  int _totalCount = 0;

  int page = 0;
  int pageSize = 10;

  bool get isLoading => _loading;
  String? get error => _error;
  List<T> get items => _items;
  int get totalCount => _totalCount;
  int get lastPage => (_totalCount == 0) ? 0 : ((_totalCount - 1) ~/ pageSize);

  /// Djeca vraćaju PagedResult za zadani search.
  Future<PagedResult<T>> fetch(S search);

  /// Djeca moraju dati aktivni search state.
  S buildSearch();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final pr = await fetch(buildSearch());
      //_items = List<T>.from(pr.items); probati ovo ako bi bio opet neki error s brisanjem
      _items = pr.items;
      _totalCount = pr.totalCount ?? (_items.length + page * pageSize);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

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
    notifyListeners();
  }

  void setError(String? err) {
    _error = err;
    notifyListeners();
  }
}
