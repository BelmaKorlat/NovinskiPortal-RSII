import 'package:flutter/foundation.dart';
import '../../models/common/paging.dart';
import '../../core/api_error.dart';

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
  Future<void> load({bool append = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final pr = await fetch(buildSearch());

      if (append) {
        _items = [..._items, ...pr.items];
      } else {
        _items = pr.items;
      }

      _totalCount = pr.totalCount ?? (_items.length + page * pageSize);
    } on ApiException catch (ex) {
      _error = ex.message;
    } catch (e, s) {
      _error = e.toString();
      if (kDebugMode) {
        print('PagedProvider error: $e\n$s');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
