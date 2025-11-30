import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/core/api_error.dart';
import 'package:novinskiportal_desktop/core/paging.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../models/admin_comment_models.dart';

class AdminCommentService extends BaseService {
  static const String _base = '/api/AdminComments';

  Future<PagedResult<AdminCommentReportResponse>> getPage(
    AdminCommentReportSearch search,
  ) async {
    try {
      final res = await dio.get(_base, queryParameters: search.toQuery());
      return mapPagedResponse<AdminCommentReportResponse>(
        res.data,
        (m) => AdminCommentReportResponse.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješan GET prijavljenih komentara.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<AdminCommentDetailReportResponse> getDetail(int commentId) async {
    try {
      final res = await dio.get('$_base/$commentId/detail');

      if (res.data is Map<String, dynamic>) {
        return AdminCommentDetailReportResponse.fromJson(
          res.data as Map<String, dynamic>,
        );
      }

      throw ApiException(message: 'Neočekivan oblik odgovora za detalje.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Neuspješno dobavljanje detalja komentara.');
    }
  }

  Future<void> hide(int id) async {
    try {
      await dio.post('$_base/$id/hide');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri sakrivanju komentara.');
    }
  }

  Future<void> softDelete(int id) async {
    try {
      await dio.delete('$_base/$id/soft-delete');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri brisanju komentara.');
    }
  }

  Future<void> rejectPendingReports(int id, {String? adminNote}) async {
    try {
      final body = <String, dynamic>{};
      final note = adminNote?.trim();
      if (note != null && note.isNotEmpty) {
        body['adminNote'] = note;
      }

      await dio.post('$_base/$id/reports/reject-pending', data: body);
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri odbijanju pending prijava.');
    }
  }

  Future<void> banAuthor(int commentId, BanCommentAuthorRequest request) async {
    try {
      await dio.post('$_base/$commentId/ban-author', data: request.toJson());
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri zabrani komentarisanja.');
    }
  }
}
