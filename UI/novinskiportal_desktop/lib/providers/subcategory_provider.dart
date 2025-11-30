import 'package:novinskiportal_desktop/core/notification_service.dart';
import 'package:novinskiportal_desktop/providers/paged_crud_mixin.dart';
import '../models/subcategory_models.dart';
import '../services/subcategory_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class SubcategoryProvider
    extends PagedProvider<SubcategoryDto, SubcategorySearch>
    with PagedCrud<SubcategoryDto, SubcategorySearch> {
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
    await runCrud(
      () => _service.create(r),
      successMessage: 'Uspješno dodano!',
      genericError: 'Greška pri dodavanju potkategorije.',
    );
  }

  Future<void> update(int id, UpdateSubcategoryRequest r) async {
    await runCrud(
      () => _service.update(id, r),
      successMessage: 'Uspješno ažurirano!',
      genericError: 'Greška pri ažuriranju potkategorije.',
    );
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
    await runCrud(
      () => _service.delete(id),
      successMessage: 'Uspješno izbrisano!',
      genericError: 'Greška pri brisanju potkategorije.',
    );
  }
}
