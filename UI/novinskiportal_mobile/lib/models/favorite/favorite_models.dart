import 'package:novinskiportal_mobile/models/article/article_models.dart';

class FavoriteDto {
  final int id;
  final int articleId;
  final DateTime createdAt;
  final ArticleDto article;

  FavoriteDto({
    required this.id,
    required this.articleId,
    required this.createdAt,
    required this.article,
  });

  factory FavoriteDto.fromJson(Map<String, dynamic> j) => FavoriteDto(
    id: j['id'] as int,
    articleId: j['articleId'] as int,
    createdAt: (DateTime.parse(j['createdAt'] as String)).toLocal(),
    article: ArticleDto.fromJson(j['article'] as Map<String, dynamic>),
  );
}
