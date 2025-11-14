import 'package:novinskiportal_desktop/core/notification_service.dart';

import '../models/category_models.dart';
import '../services/category_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class CategoryProvider extends PagedProvider<CategoryDto, CategorySearch> {
  final _service = CategoryService();

  bool? active;
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
    try {
      await _service.create(r);
      await load();
      NotificationService.success('Notifikacija', 'Uspješno dodano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri dodavanju kategorije.');
      rethrow;
    }
  }

  Future<void> update(int id, UpdateCategoryRequest r) async {
    try {
      await _service.update(id, r);
      await load();
      NotificationService.success('Notifikacija', 'Uspješno ažurirano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri ažuriranju kategorije.');
      rethrow;
    }
  }

  Future<void> toggle(int id) async {
    try {
      final fresh = await _service.toggleStatus(id);
      final i = items.indexWhere((x) => x.id == id);
      if (i != -1) {
        items[i] = fresh;
        notifyListeners();
      }
      final msg = fresh.active
          ? 'Uspješno aktivirano!'
          : 'Uspješno deaktivirano!';
      NotificationService.success('Notifikacija', msg);
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri promjeni statusa.');
    }
  }

  Future<void> remove(int id) async {
    await _service.delete(id);
    items.removeWhere((x) => x.id == id);
    notifyListeners();
    NotificationService.success('Notifikacija', 'Uspješno izbrisano!');
  }
}
