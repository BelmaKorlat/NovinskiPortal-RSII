import 'package:novinskiportal_desktop/core/notification_service.dart';
import 'package:novinskiportal_desktop/providers/paged_crud_mixin.dart';
import '../models/admin_user_models.dart';
import '../services/admin_user_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class AdminUserProvider extends PagedProvider<UserAdminDto, UserAdminSearch>
    with PagedCrud<UserAdminDto, UserAdminSearch> {
  final _service = AdminUserService();

  String fts = '';
  int? roleId;
  bool? active;
  @override
  UserAdminSearch buildSearch() => UserAdminSearch(
    fts: fts.trim().isEmpty ? null : fts.trim(),
    roleId: roleId,
    active: active,
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
  );

  @override
  Future<PagedResult<UserAdminDto>> fetch(UserAdminSearch s) {
    return _service.getPage(s);
  }

  Future<void> create(CreateAdminUserRequest r) async {
    await runCrud(
      () => _service.create(r),
      successMessage: 'Uspješno dodano!',
      genericError: 'Greška pri dodavanju korisnika.',
    );
  }

  Future<void> update(int id, UpdateAdminUserRequest r) async {
    await runCrud(
      () => _service.update(id, r),
      successMessage: 'Uspješno ažurirano!',
      genericError: 'Greška pri ažuriranju korisnika.',
    );
  }

  Future<void> changePasswordForUser(
    int id,
    AdminChangePasswordRequest r,
  ) async {
    await runCrud(
      () => _service.changePasswordForUser(id, r),
      successMessage: 'Uspješan reset lozinke!',
      genericError: 'Greška pri reset-u lozinke.',
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

  Future<void> changeRole(int id, int roleId) async {
    try {
      final fresh = await _service.changeRole(id, roleId);
      final i = items.indexWhere((x) => x.id == id);
      if (i != -1) {
        items[i] = fresh;
        notifyListeners();
      }
      NotificationService.success('Notifikacija', 'Uloga je promijenjena.');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri promjeni uloge.');
    }
  }

  Future<void> softDelete(int id) async {
    await runCrud(
      () => _service.softDelete(id),
      successMessage: 'Uspješno izbrisano!',
      genericError: 'Greška pri brisanju korisnika.',
    );
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      return await _service.isUsernameTaken(username);
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEmailTaken(String email) async {
    try {
      return await _service.isEmailTaken(email);
    } catch (_) {
      return false;
    }
  }
}
