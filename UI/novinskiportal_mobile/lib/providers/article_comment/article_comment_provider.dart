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
      lastError = _mapCommentError(ex);
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

  Future<bool> reportComment({
    required int commentId,
    required String reason,
  }) async {
    try {
      lastError = null;
      notifyListeners();

      final updated = await _service.report(
        commentId: commentId,
        reason: reason,
      );

      final index = items.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        items[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (ex) {
      lastError = _mapCommentError(ex);
      notifyListeners();
      return false;
    } catch (_) {
      lastError = 'Greška pri prijavi komentara.';
      notifyListeners();
      return false;
    }
  }

  String _mapCommentError(ApiException ex) {
    switch (ex.code) {
      case 'COMMENT_BANNED':
        return 'Zabranjeno komentarisanje. Obratite se administratoru.';

      case 'COMMENT_ARTICLE_NOT_FOUND':
        return 'Članak koji pokušavate komentarisati ne postoji.';

      case 'COMMENT_USER_NOT_FOUND':
        return 'Korisnik ne postoji ili je deaktiviran.';

      case 'COMMENT_CREATE_FAILED':
        return 'Neuspješno slanje komentara. Pokušajte ponovo.';

      // REPORT
      case 'COMMENT_REPORT_REASON_REQUIRED':
        return 'Razlog prijave je obavezan.';

      case 'COMMENT_REPORT_NOT_FOUND':
        return 'Komentar koji pokušavate prijaviti ne postoji.';

      case 'COMMENT_REPORT_OWN_COMMENT':
        return 'Ne možete prijaviti vlastiti komentar.';

      case 'COMMENT_REPORT_ALREADY_REPORTED':
        return 'Već ste prijavili ovaj komentar.';

      case 'COMMENT_REPORT_FAILED':
        return 'Neuspješna prijava komentara. Pokušajte ponovo.';

      default:
        final msg = ex.message.trim();
        if (msg.isEmpty) {
          return 'Došlo je do greške. Pokušajte ponovo.';
        }
        return msg;
    }
  }
}
