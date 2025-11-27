import 'package:novinskiportal_mobile/models/common/base_search.dart';

class ArticleCommentResponse {
  final int id;
  final int articleId;
  final int userId;
  final String? username;
  final int? parentCommentId;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int dislikesCount;
  final int reportsCount;
  final bool isOwner;
  final int? userVote;

  ArticleCommentResponse({
    required this.id,
    required this.articleId,
    required this.userId,
    this.username,
    this.parentCommentId,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.dislikesCount,
    required this.reportsCount,
    required this.isOwner,
    this.userVote,
  });

  factory ArticleCommentResponse.fromJson(Map<String, dynamic> json) {
    return ArticleCommentResponse(
      id: json['id'] as int,
      articleId: json['articleId'] as int,
      userId: json['userId'] as int,
      username: json['username'] as String?,
      parentCommentId: json['parentCommentId'] as int?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      likesCount: json['likesCount'] as int,
      dislikesCount: json['dislikesCount'] as int,
      reportsCount: json['reportsCount'] as int,
      isOwner: json['isOwner'] as bool,
      userVote: json['userVote'] as int?,
    );
  }
}

class ArticleCommentCreateRequest {
  final String content;
  final int? parentCommentId;

  ArticleCommentCreateRequest({required this.content, this.parentCommentId});

  Map<String, dynamic> toJson() {
    return {'content': content, 'parentCommentId': parentCommentId};
  }
}

class ArticleCommentVoteRequest {
  final int commentId;
  final int value;

  ArticleCommentVoteRequest({required this.commentId, required this.value});

  Map<String, dynamic> toJson() {
    return {'commentId': commentId, 'value': value};
  }
}

class ArticleCommentSearch extends BaseSearch {
  final int articleId;

  ArticleCommentSearch({
    required this.articleId,
    super.page = 0,
    super.pageSize = 20,
    super.includeTotalCount = true,
    super.retrieveAll = false,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();
    q['articleId'] = articleId;
    return q;
  }
}
