import 'package:flutter/foundation.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

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

  Future<PagedResult<T>> fetch(S search);

  S buildSearch();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final pr = await fetch(buildSearch());
      _items = pr.items;
      _totalCount = pr.totalCount ?? (_items.length + page * pageSize);
    } on ApiException catch (ex) {
      _error = ex.message;
    } catch (_) {
      _error = 'Greška pri učitavanju.';
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
  }

  void setError(String? err) {
    _error = err;
    notifyListeners();
  }
}
