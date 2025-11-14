import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/base_search.dart';

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
  );
}

/// 2) DTO za detalj (mapira tvoj ArticleDetailResponse)
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

/// 3) Search objekt za listu članaka.
/// Ako backend podržava još filtera, samo ih dodaj.
class ArticleSearch extends BaseSearch {
  final int? categoryId;
  final int? subcategoryId;
  final int? userId;

  const ArticleSearch({
    this.categoryId,
    this.subcategoryId,
    this.userId,
    super.fts,
    super.page = 0,
    super.pageSize = 10,
    super.includeTotalCount = true,
    super.retrieveAll = false,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();
    if (categoryId != null) q['categoryId'] = categoryId;
    if (subcategoryId != null) q['subcategoryId'] = subcategoryId;
    if (userId != null) q['userId'] = userId;
    return q;
  }
}

class PhotoUpload {
  final String fileName;
  final Uint8List bytes;

  PhotoUpload({required this.fileName, required this.bytes});
}

class CreateArticleRequest {
  final String headline;
  final String subheadline;
  final String shortText;
  final String text;
  final DateTime publishedAt;
  final bool active;
  final bool hideFullName;
  final bool breakingNews;
  final bool live;
  final int categoryId;
  final int subcategoryId;
  final int userId;
  final PhotoUpload mainPhoto;
  final List<PhotoUpload> additionalPhotos;

  CreateArticleRequest({
    required this.headline,
    required this.subheadline,
    required this.shortText,
    required this.text,
    required this.publishedAt,
    required this.active,
    required this.hideFullName,
    required this.breakingNews,
    required this.live,
    required this.categoryId,
    required this.subcategoryId,
    required this.userId,
    required this.mainPhoto,
    List<PhotoUpload>? additionalPhotos,
  }) : additionalPhotos = additionalPhotos ?? const [];

  FormData toFormData() {
    final map = <String, dynamic>{
      'headline': headline,
      'subheadline': subheadline,
      'shortText': shortText,
      'text': text,
      'publishedAt': publishedAt.toIso8601String(),
      'active': active,
      'hideFullName': hideFullName,
      'breakingNews': breakingNews,
      'live': live,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'userId': userId,
      'mainPhoto': MultipartFile.fromBytes(
        mainPhoto.bytes,
        filename: mainPhoto.fileName,
      ),
    };

    if (additionalPhotos.isNotEmpty) {
      map['additionalPhotos'] = additionalPhotos
          .map((p) => MultipartFile.fromBytes(p.bytes, filename: p.fileName))
          .toList();
    }

    return FormData.fromMap(map);
  }
}

class UpdateArticleRequest {
  final String? headline;
  final String? subheadline;
  final String? shortText;
  final String? text;
  final DateTime? publishedAt;
  final bool? active;
  final bool? hideFullName;
  final bool? breakingNews;
  final bool? live;
  final int? categoryId;
  final int? subcategoryId;
  final int? userId;
  final PhotoUpload? mainPhoto;
  final List<PhotoUpload>? additionalPhotos;

  UpdateArticleRequest({
    this.headline,
    this.subheadline,
    this.shortText,
    this.text,
    this.publishedAt,
    this.active,
    this.hideFullName,
    this.breakingNews,
    this.live,
    this.categoryId,
    this.subcategoryId,
    this.userId,
    this.mainPhoto,
    this.additionalPhotos,
  });

  FormData toFormData() {
    final map = <String, dynamic>{};

    void put<T>(String k, T? v) {
      if (v == null) return;
      map[k] = v;
    }

    put('headline', headline);
    put('subheadline', subheadline);
    put('shortText', shortText);
    put('text', text);
    if (publishedAt != null) {
      map['publishedAt'] = publishedAt!.toIso8601String();
    }
    put('active', active);
    put('hideFullName', hideFullName);
    put('breakingNews', breakingNews);
    put('live', live);
    put('categoryId', categoryId);
    put('subcategoryId', subcategoryId);
    put('userId', userId);

    if (mainPhoto != null) {
      map['mainPhoto'] = MultipartFile.fromBytes(
        mainPhoto!.bytes,
        filename: mainPhoto!.fileName,
      );
    }

    if (additionalPhotos != null) {
      map['additionalPhotos'] = additionalPhotos!
          .map((p) => MultipartFile.fromBytes(p.bytes, filename: p.fileName))
          .toList();
    }

    return FormData.fromMap(map);
  }
}
