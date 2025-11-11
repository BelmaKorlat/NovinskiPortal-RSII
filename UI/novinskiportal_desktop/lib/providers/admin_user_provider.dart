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
  bool includeDeleted = false;
  @override
  UserAdminSearch buildSearch() => UserAdminSearch(
    fts: fts.trim().isEmpty ? null : fts.trim(),
    roleId: roleId,
    active: active,
    includeDeleted: includeDeleted,
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
  );

  @override
  Future<PagedResult<UserAdminDto>> fetch(UserAdminSearch s) {
    return _service.getPage(s);
  }

  Future<void> create(CreateAdminUserRequest r) async {
    await _service.create(r);
    await load();
    NotificationService.success('Notifikacija', 'Uspješno dodano!');
  }

  Future<void> update(int id, UpdateAdminUserRequest r) async {
    await _service.update(id, r);
    await load();
    NotificationService.success('Notifikacija', 'Uspješno ažurirano!');
  }

  Future<void> setRoleFilter(int? value) async {
    roleId = value;
    page = 0;
    await load();
  }

  Future<void> setActiveFilter(bool? value) async {
    active = value;
    page = 0;
    await load();
  }

  Future<void> setIncludeDeleted(bool value) async {
    includeDeleted = value;
    page = 0;
    await load();
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
      // ako ne prikazujemo obrisane, ukloni iz liste
      if (!includeDeleted) {
        items.removeWhere((x) => x.id == id);
        notifyListeners();
      } else {
        await load();
      }
      NotificationService.success('Notifikacija', 'Korisnik je soft obrisan.');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri soft delete korisnika.');
    }
  }

  Future<void> restore(int id) async {
    try {
      await _service.restore(id);
      await load();
      NotificationService.success('Notifikacija', 'Korisnik je vraćen.');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri vraćanju korisnika.');
    }
  }

  Future<void> remove(int id) async {
    await _service.delete(id);
    items.removeWhere((x) => x.id == id);
    notifyListeners();
    NotificationService.success('Notifikacija', 'Uspješno izbrisano!');
  }
}
