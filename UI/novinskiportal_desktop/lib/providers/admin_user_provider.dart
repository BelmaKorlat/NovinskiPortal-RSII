import 'package:novinskiportal_desktop/core/notification_service.dart';
import '../models/admin_user_models.dart';
import '../services/admin_user_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class AdminUserProvider extends PagedProvider<UserAdminDto, UserAdminSearch> {
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
    try {
      await _service.create(r);
      await load();
      NotificationService.success('Notifikacija', 'Uspješno dodano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri dodavanju korisnika.');
      rethrow;
    }
  }

  Future<void> update(int id, UpdateAdminUserRequest r) async {
    try {
      await _service.update(id, r);
      await load();
      NotificationService.success('Notifikacija', 'Uspješno ažurirano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri ažuriranju korisnika.');
      rethrow;
    }
  }

  Future<void> changePasswordForUser(
    int id,
    AdminChangePasswordRequest r,
  ) async {
    try {
      await _service.changePasswordForUser(id, r);
      await load();
      NotificationService.success('Notifikacija', 'Uspješan reset lozinke!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri reset-u lozinke.');
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
    try {
      await _service.softDelete(id);
      items.removeWhere((x) => x.id == id);
      notifyListeners();

      NotificationService.success('Notifikacija', 'Uspješno izbrisano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri brisanju korisnika.');
    }
  }

  Future<void> remove(int id) async {
    await _service.delete(id);
    items.removeWhere((x) => x.id == id);
    notifyListeners();
    NotificationService.success('Notifikacija', 'Uspješno izbrisano!');
  }
}
