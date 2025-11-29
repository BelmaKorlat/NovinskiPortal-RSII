import 'package:novinskiportal_desktop/core/notification_service.dart';
import 'package:novinskiportal_desktop/core/paging.dart';
import 'package:novinskiportal_desktop/models/admin_comment_models.dart';
import 'package:novinskiportal_desktop/providers/paged_provider.dart';
import 'package:novinskiportal_desktop/services/admin_comment_service.dart';
import 'package:novinskiportal_desktop/core/api_error.dart';

class AdminCommentProvider
    extends
        PagedProvider<AdminCommentReportResponse, AdminCommentReportSearch> {
  final _service = AdminCommentService();

  ArticleCommentReportStatus? status;

  @override
  AdminCommentReportSearch buildSearch() => AdminCommentReportSearch(
    status: status,
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
  );

  @override
  Future<PagedResult<AdminCommentReportResponse>> fetch(
    AdminCommentReportSearch s,
  ) {
    return _service.getPage(s);
  }

  Future<void> hide(int id) async {
    try {
      await _service.hide(id);
      await load();
      NotificationService.success(
        'Notifikacija',
        'Komentar je sakriven, pending prijave su odobrene.',
      );
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri sakrivanju komentara.');
    }
  }

  Future<void> softDelete(int id) async {
    try {
      await _service.softDelete(id);
      await load();
      NotificationService.success('Notifikacija', 'Uspješno izbrisano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri brisanju komentara.');
    }
  }

  Future<void> rejectPendingReports(int id, {String? adminNote}) async {
    try {
      await _service.rejectPendingReports(id, adminNote: adminNote);
      await load();
      NotificationService.success(
        'Notifikacija',
        'Sve pending prijave su odbijene.',
      );
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error(
        'Greška',
        'Greška pri odbijanju pending prijava.',
      );
    }
  }

  Future<void> banAuthor(int id, BanCommentAuthorRequest request) async {
    try {
      await _service.banAuthor(id, request);
      await load();
      NotificationService.success(
        'Notifikacija',
        'Zabrana komentarisanja je postavljena.',
      );
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri zabrani komentarisanja.');
    }
  }
}
