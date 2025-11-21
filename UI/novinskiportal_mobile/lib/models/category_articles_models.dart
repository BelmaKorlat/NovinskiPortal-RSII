import 'article_models.dart';

class CategoryArticlesDto {
  final int id;
  final String name;
  final String color;
  final List<ArticleDto> articles;

  CategoryArticlesDto({
    required this.id,
    required this.name,
    required this.color,
    required this.articles,
  });

  factory CategoryArticlesDto.fromJson(Map<String, dynamic> json) {
    return CategoryArticlesDto(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      articles: (json['articles'] as List<dynamic>)
          .map((e) => ArticleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
