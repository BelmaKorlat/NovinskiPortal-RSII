import 'package:novinskiportal_desktop/core/api_error.dart';
import 'package:novinskiportal_desktop/core/notification_service.dart';
import 'package:novinskiportal_desktop/core/paging.dart';
import 'package:novinskiportal_desktop/providers/paged_provider.dart';
import '../models/news_report_models.dart';
import '../services/news_report_service.dart';

class NewsReportProvider
    extends PagedProvider<NewsReportDto, NewsReportSearch> {
  final _service = NewsReportService();

  NewsReportStatus? statusFilter = NewsReportStatus.pending;
  String fts = '';

  int pendingCount = 0;
  @override
  NewsReportSearch buildSearch() => NewsReportSearch(
    status: statusFilter,
    fts: fts.trim().isEmpty ? null : fts.trim(),
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
  );

  @override
  Future<PagedResult<NewsReportDto>> fetch(NewsReportSearch s) {
    return _service.getPage(s);
  }

  Future<NewsReportDto?> getById(int id) async {
    try {
      return await _service.getById(id);
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      return null;
    } catch (_) {
      NotificationService.error(
        'Greška',
        'Greška pri učitavanju detalja dojave.',
      );
      return null;
    }
  }

  Future<void> changeStatus({
    required int id,
    required NewsReportStatus status,
    String? adminNote,
    int? articleId,
  }) async {
    final req = UpdateNewsReportStatusRequest(
      status: status,
      adminNote: adminNote,
      articleId: articleId,
    );

    try {
      await _service.updateStatus(id, req);

      await load();
      await loadPendingCount();

      String msg;
      if (status == NewsReportStatus.approved) {
        msg = 'Dojava je prihvaćena.';
      } else if (status == NewsReportStatus.rejected) {
        msg = 'Dojava je odbijena.';
      } else {
        msg = 'Status dojave je ažuriran.';
      }

      NotificationService.success('Notifikacija', msg);
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error(
        'Greška',
        'Greška pri ažuriranju statusa dojave.',
      );
      rethrow;
    }
  }

  Future<void> loadPendingCount() async {
    try {
      pendingCount = await _service.getPendingCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> openFile(NewsReportFileDto file) async {
    try {
      await _service.openFile(file);
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri otvaranju fajla.');
    }
  }
}
