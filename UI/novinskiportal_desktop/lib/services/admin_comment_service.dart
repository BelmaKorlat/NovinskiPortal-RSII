import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/core/api_client.dart';
import 'package:novinskiportal_desktop/core/api_error.dart';
import 'package:novinskiportal_desktop/core/paging.dart';

import '../models/admin_comment_models.dart';

class AdminCommentService {
  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/AdminComments';

  ApiException _asApi(
    DioException e, {
    String fallback = 'Došlo je do greške.',
  }) {
    if (e.error is ApiException) return e.error as ApiException;

    final code = e.response?.statusCode;
    final data = e.response?.data;
    return ApiException(
      statusCode: code,
      message: humanMessage(code, data, fallback),
    );
  }

  Future<PagedResult<AdminCommentReportResponse>> getPage(
    AdminCommentReportSearch search,
  ) async {
    try {
      final res = await _dio.get(_base, queryParameters: search.toQuery());

      final data = res.data;

      final list = readItems(data);
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(AdminCommentReportResponse.fromJson)
          .toList();

      final total = readTotalCount(data) ?? items.length;

      return PagedResult(items: items, totalCount: total);
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješan GET prijavljenih komentara.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora.');
    }
  }

  Future<AdminCommentDetailReportResponse> getDetail(int commentId) async {
    try {
      final res = await _dio.get('$_base/$commentId/detail');

      if (res.data is Map<String, dynamic>) {
        return AdminCommentDetailReportResponse.fromJson(
          res.data as Map<String, dynamic>,
        );
      }

      throw ApiException(message: 'Neočekivan oblik odgovora za detalje.');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Neuspješno dobavljanje detalja komentara.');
    }
  }

  Future<void> hide(int id) async {
    try {
      await _dio.post('$_base/$id/hide');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri sakrivanju komentara.');
    }
  }

  Future<void> softDelete(int id) async {
    try {
      await _dio.delete('$_base/$id/soft-delete');
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri brisanju komentara.');
    }
  }

  Future<void> rejectPendingReports(int id, {String? adminNote}) async {
    try {
      final body = <String, dynamic>{};
      final note = adminNote?.trim();
      if (note != null && note.isNotEmpty) {
        body['adminNote'] = note;
      }

      await _dio.post('$_base/$id/reports/reject-pending', data: body);
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri odbijanju pending prijava.');
    }
  }

  Future<void> banAuthor(int commentId, BanCommentAuthorRequest request) async {
    try {
      await _dio.post('$_base/$commentId/ban-author', data: request.toJson());
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri zabrani komentarisanja.');
    }
  }
}
