import 'package:novinskiportal_desktop/core/notification_service.dart';
import 'package:novinskiportal_desktop/providers/paged_crud_mixin.dart';
import '../models/category_models.dart';
import '../services/category_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class CategoryProvider extends PagedProvider<CategoryDto, CategorySearch>
    with PagedCrud<CategoryDto, CategorySearch> {
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

  // Future<void> create(CreateCategoryRequest r) async {
  //   try {
  //     await _service.create(r);
  //     await load();
  //     NotificationService.success('Notifikacija', 'Uspješno dodano!');
  //   } on ApiException catch (ex) {
  //     NotificationService.error('Greška', ex.message);
  //     rethrow;
  //   } catch (_) {
  //     NotificationService.error('Greška', 'Greška pri dodavanju kategorije.');
  //     rethrow;
  //   }
  // }

  Future<void> create(CreateCategoryRequest r) async {
    await runCrud(
      () => _service.create(r),
      successMessage: 'Uspješno dodano!',
      genericError: 'Greška pri dodavanju kategorije.',
    );
  }

  Future<void> update(int id, UpdateCategoryRequest r) async {
    await runCrud(
      () => _service.update(id, r),
      successMessage: 'Uspješno ažurirano!',
      genericError: 'Greška pri ažuriranju kategorije.',
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
      genericError: 'Greška pri brisanju kategorije.',
    );
  }
}
