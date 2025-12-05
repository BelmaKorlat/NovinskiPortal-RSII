import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/article_comment/article_comment_models.dart';
import 'package:novinskiportal_mobile/models/common/paging.dart';
import 'package:novinskiportal_mobile/services/base_service.dart';
import '../core/api_error.dart';

class ArticleCommentService extends BaseService {
  static const String _base = '/api/ArticleComments';

  Future<PagedResult<ArticleCommentResponse>> get(
    ArticleCommentSearch search,
  ) async {
    try {
      final response = await dio.get(_base, queryParameters: search.toQuery());

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
      throw asApi(e, fallback: 'Greška pri dobavljanju komentara.');
    }
  }

  Future<ArticleCommentResponse> create({
    required int articleId,
    required ArticleCommentCreateRequest request,
  }) async {
    try {
      final response = await dio.post(
        _base,
        queryParameters: {'articleId': articleId},
        data: request.toJson(),
      );

      return ArticleCommentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }

      throw asApi(e, fallback: 'Greška pri slanju komentara.');
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

      final response = await dio.post('$_base/vote', data: request.toJson());

      return ArticleCommentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri glasanju za komentar.');
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

      final response = await dio.post('$_base/report', data: request.toJson());

      return ArticleCommentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }

      throw asApi(e, fallback: 'Greška pri prijavi komentara.');
    }
  }
}
