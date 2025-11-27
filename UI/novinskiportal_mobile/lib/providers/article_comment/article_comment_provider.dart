import 'package:novinskiportal_mobile/models/article_comment/article_comment_models.dart';
import 'package:novinskiportal_mobile/models/common/paging.dart';
import 'package:novinskiportal_mobile/providers/page/paged_provider.dart';
import 'package:novinskiportal_mobile/services/article_comment_service.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';

class ArticleCommentProvider
    extends PagedProvider<ArticleCommentResponse, ArticleCommentSearch> {
  final ArticleCommentService _service = ArticleCommentService();

  int articleId;

  String? lastError;

  bool _voting = false;
  bool get isVoting => _voting;

  ArticleCommentProvider({required this.articleId}) {
    pageSize = 20;
  }

  @override
  Future<PagedResult<ArticleCommentResponse>> fetch(
    ArticleCommentSearch search,
  ) {
    return _service.get(search);
  }

  @override
  ArticleCommentSearch buildSearch() {
    return ArticleCommentSearch(
      articleId: articleId,
      page: page,
      pageSize: pageSize,
    );
  }

  bool get hasMore => items.length < totalCount;

  Future<void> loadInitial(int newArticleId) async {
    articleId = newArticleId;
    page = 0;
    await load();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    page += 1;
    await load(append: true);
  }

  Future<bool> create({required String content, int? parentCommentId}) async {
    try {
      lastError = null;

      final request = ArticleCommentCreateRequest(
        content: content,
        parentCommentId: parentCommentId,
      );

      await _service.create(articleId: articleId, request: request);

      page = 0;
      await load();

      return true;
    } on ApiException catch (ex) {
      lastError = ex.message;
      notifyListeners();
      return false;
    } catch (e) {
      lastError = 'Greška pri slanju komentara.';
      notifyListeners();
      return false;
    }
  }

  Future<void> voteOnComment({
    required int commentId,
    required int value,
  }) async {
    if (_voting) return;

    _voting = true;
    lastError = null;
    notifyListeners();

    try {
      final updated = await _service.vote(commentId: commentId, value: value);

      final index = items.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        items[index] = updated;
      }
    } on ApiException catch (ex) {
      lastError = ex.message;
    } catch (_) {
      lastError = 'Greška pri glasanju za komentar.';
    } finally {
      _voting = false;
      notifyListeners();
    }
  }
}
