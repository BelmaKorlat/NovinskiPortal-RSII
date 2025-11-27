import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/article_comment/article_comment_models.dart';
import 'package:novinskiportal_mobile/models/common/paging.dart';
import '../core/api_client.dart';
import '../core/api_error.dart';

class ArticleCommentService {
  final Dio _dio = ApiClient().dio;
  static const String _base = '/api/ArticleComments';

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

  Future<PagedResult<ArticleCommentResponse>> get(
    ArticleCommentSearch search,
  ) async {
    try {
      final response = await _dio.get(_base, queryParameters: search.toQuery());

      final data = response.data as Map<String, dynamic>;
      final itemsJson = data['items'] as List<dynamic>;
      final totalCount = data['totalCount'] as int;

      final items = itemsJson
          .map(
            (e) => ArticleCommentResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      return PagedResult<ArticleCommentResponse>(
        items: items,
        totalCount: totalCount,
      );
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri dobavljanju komentara.');
    }
  }

  Future<ArticleCommentResponse> create({
    required int articleId,
    required ArticleCommentCreateRequest request,
  }) async {
    try {
      final response = await _dio.post(
        _base,
        queryParameters: {'articleId': articleId},
        data: request.toJson(),
      );

      return ArticleCommentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri slanju komentara.');
    }
  }

  Future<ArticleCommentResponse> vote({
    required int commentId,
    required int value,
  }) async {
    try {
      final request = ArticleCommentVoteRequest(
        commentId: commentId,
        value: value,
      );

      final response = await _dio.post('$_base/vote', data: request.toJson());

      return ArticleCommentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _asApi(e, fallback: 'Greška pri glasanju za komentar.');
    }
  }

  Future<ArticleCommentResponse> report({
    required int commentId,
    required String reason,
  }) async {
    try {
      final request = ArticleCommentReportRequest(
        commentId: commentId,
        reason: reason.trim(),
      );

      final response = await _dio.post('$_base/report', data: request.toJson());

      return ArticleCommentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ApiException(
          message:
              'Prijava komentara nije prihvaćena. Moguće je da ste ovaj komentar već prijavili.',
        );
      }

      throw _asApi(e, fallback: 'Greška pri prijavi komentara.');
    }
  }
}
