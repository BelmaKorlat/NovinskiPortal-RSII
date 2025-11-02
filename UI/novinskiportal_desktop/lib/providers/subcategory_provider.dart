import 'package:novinskiportal_desktop/core/notification_service.dart';
import '../models/subcategory_models.dart';
import '../services/subcategory_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class SubcategoryProvider
    extends PagedProvider<SubcategoryDto, SubcategorySearch> {
  final _service = SubcategoryService();

  int? categoryId;
  bool? active;
  @override
  SubcategorySearch buildSearch() => SubcategorySearch(
    categoryId: categoryId,
    active: active,
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
  );

  @override
  Future<PagedResult<SubcategoryDto>> fetch(SubcategorySearch s) {
    return _service.getPage(s);
  }

  Future<void> create(CreateSubcategoryRequest r) async {
    await _service.create(r);
    await load();
    NotificationService.success('Notifikacija', 'Uspješno dodano!');
  }

  Future<void> update(int id, UpdateSubcategoryRequest r) async {
    await _service.update(id, r);
    await load();
    NotificationService.success('Notifikacija', 'Uspješno ažurirano!');
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
