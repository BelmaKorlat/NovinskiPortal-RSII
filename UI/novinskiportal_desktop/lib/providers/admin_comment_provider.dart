import 'package:novinskiportal_desktop/core/paging.dart';
import 'package:novinskiportal_desktop/models/admin_comment_models.dart';
import 'package:novinskiportal_desktop/providers/paged_crud_mixin.dart';
import 'package:novinskiportal_desktop/providers/paged_provider.dart';
import 'package:novinskiportal_desktop/services/admin_comment_service.dart';

class AdminCommentProvider
    extends PagedProvider<AdminCommentReportResponse, AdminCommentReportSearch>
    with PagedCrud<AdminCommentReportResponse, AdminCommentReportSearch> {
  final _service = AdminCommentService();

  ArticleCommentReportStatus? status = ArticleCommentReportStatus.pending;
  int pendingCount = 0;

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
    await runCrud(
      () => _service.hide(id),
      successMessage: 'Komentar je sakriven, prijave su odobrene.',
      genericError: 'Greška pri sakrivanju komentara.',
    );
    await loadPendingCount();
  }

  Future<void> softDelete(int id) async {
    await runCrud(
      () => _service.softDelete(id),
      successMessage: 'Uspješno izbrisano!',
      genericError: 'Greška pri brisanju komentara.',
    );
    await loadPendingCount();
  }

  Future<void> rejectPendingReports(int id, {String? adminNote}) async {
    await runCrud(
      () => _service.rejectPendingReports(id, adminNote: adminNote),
      successMessage: 'Sve prijave su odbijene.',
      genericError: 'Greška pri odbijanju prijava.',
    );
    await loadPendingCount();
  }

  Future<void> banAuthor(int id, BanCommentAuthorRequest request) async {
    await runCrud(
      () => _service.banAuthor(id, request),
      successMessage: 'Zabrana komentarisanja je postavljena.',
      genericError: 'Greška pri zabrani komentarisanja.',
    );
    await loadPendingCount();
  }

  Future<void> loadPendingCount() async {
    try {
      pendingCount = await _service.getPendingCount();
      notifyListeners();
    } catch (_) {}
  }
}
