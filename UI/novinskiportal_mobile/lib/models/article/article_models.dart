import 'dart:typed_data';
import '../common/base_search.dart';

class ArticleDto {
  final int id;
  final String headline;
  final String subheadline;
  final DateTime createdAt;
  final DateTime publishedAt;
  final bool active;
  final bool hideFullName;
  final bool breakingNews;
  final bool live;
  final String category;
  final String subcategory;
  final String user;
  final String mainPhotoPath;
  final String color;
  final int commentsCount;

  ArticleDto({
    required this.id,
    required this.headline,
    required this.subheadline,
    required this.createdAt,
    required this.publishedAt,
    required this.active,
    required this.hideFullName,
    required this.breakingNews,
    required this.live,
    required this.category,
    required this.subcategory,
    required this.user,
    required this.mainPhotoPath,
    required this.color,
    required this.commentsCount,
  });

  factory ArticleDto.fromJson(Map<String, dynamic> j) => ArticleDto(
    id: j['id'] as int,
    headline: j['headline'] as String,
    subheadline: j['subheadline'] as String,
    createdAt: (DateTime.parse(j['createdAt'] as String)).toLocal(),
    publishedAt: (DateTime.parse(j['publishedAt'] as String)).toLocal(),
    active: j['active'] as bool,
    hideFullName: j['hideFullName'] as bool,
    breakingNews: j['breakingNews'] as bool,
    live: j['live'] as bool,
    category: j['category'] as String,
    subcategory: j['subcategory'] as String,
    user: j['user'] as String,
    mainPhotoPath: j['mainPhotoPath'] as String,
    color: j['color'] as String,
    commentsCount: j['commentsCount'] as int,
  );
}

class ArticleDetailDto {
  final int id;
  final String headline;
  final String subheadline;
  final String shortText;
  final String text;
  final DateTime createdAt;
  final DateTime publishedAt;
  final bool active;
  final bool hideFullName;
  final bool breakingNews;
  final bool live;
  final int commentsCount;

  final int categoryId;
  final String category;
  final String color;

  final int subcategoryId;
  final String subcategory;

  final String user;
  final String mainPhotoPath;
  final List<String> additionalPhotos;

  ArticleDetailDto({
    required this.id,
    required this.headline,
    required this.subheadline,
    required this.shortText,
    required this.text,
    required this.createdAt,
    required this.publishedAt,
    required this.active,
    required this.hideFullName,
    required this.breakingNews,
    required this.live,
    required this.commentsCount,
    required this.categoryId,
    required this.category,
    required this.color,
    required this.subcategoryId,
    required this.subcategory,
    required this.user,
    required this.mainPhotoPath,
    required this.additionalPhotos,
  });

  factory ArticleDetailDto.fromJson(Map<String, dynamic> j) => ArticleDetailDto(
    id: j['id'] as int,
    headline: j['headline'] as String,
    subheadline: j['subheadline'] as String,
    shortText: j['shortText'] as String,
    text: j['text'] as String,
    createdAt: (DateTime.parse(j['createdAt'] as String)).toLocal(),
    publishedAt: (DateTime.parse(j['publishedAt'] as String)).toLocal(),
    active: j['active'] as bool,
    hideFullName: j['hideFullName'] as bool,
    breakingNews: j['breakingNews'] as bool,
    live: j['live'] as bool,
    commentsCount: j['commentsCount'] as int,
    categoryId: j['categoryId'] as int,
    category: j['category'] as String,
    color: j['color'] as String,
    subcategoryId: j['subcategoryId'] as int,
    subcategory: j['subcategory'] as String,
    user: j['user'] as String,
    mainPhotoPath: j['mainPhotoPath'] as String,
    additionalPhotos: (j['additionalPhotos'] as List<dynamic>).cast<String>(),
  );
}

class ArticleSearch extends BaseSearch {
  final int? categoryId;
  final int? subcategoryId;
  final int? userId;
  final String? mode;

  const ArticleSearch({
    this.categoryId,
    this.subcategoryId,
    this.userId,
    super.fts,
    super.page = 0,
    super.pageSize = 10,
    super.includeTotalCount = true,
    super.retrieveAll = false,
    this.mode,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();
    if (categoryId != null) q['categoryId'] = categoryId;
    if (subcategoryId != null) q['subcategoryId'] = subcategoryId;
    if (userId != null) q['userId'] = userId;
    if (mode != null) q['mode'] = mode;
    return q;
  }
}

class PhotoUpload {
  final String fileName;
  final Uint8List bytes;

  PhotoUpload({required this.fileName, required this.bytes});
}
