import 'package:novinskiportal_desktop/core/base_search.dart';

enum NewsReportStatus { pending, approved, rejected }

NewsReportStatus newsReportStatusFromJson(dynamic value) {
  if (value is int) {
    switch (value) {
      case 0:
        return NewsReportStatus.pending;
      case 1:
        return NewsReportStatus.approved;
      case 2:
        return NewsReportStatus.rejected;
    }
  }

  if (value is String) {
    switch (value.toLowerCase()) {
      case 'pending':
        return NewsReportStatus.pending;
      case 'approved':
        return NewsReportStatus.approved;
      case 'rejected':
        return NewsReportStatus.rejected;
    }
  }

  return NewsReportStatus.pending;
}

int newsReportStatusToJson(NewsReportStatus s) {
  return s.index;
}

class NewsReportFileDto {
  final int id;
  final String originalFileName;
  final String filePath;
  final String contentType;
  final int size;

  NewsReportFileDto({
    required this.id,
    required this.originalFileName,
    required this.filePath,
    required this.contentType,
    required this.size,
  });

  factory NewsReportFileDto.fromJson(Map<String, dynamic> j) {
    return NewsReportFileDto(
      id: j['id'] as int,
      originalFileName: j['originalFileName'] as String,
      filePath: j['filePath'] as String,
      contentType: j['contentType'] as String,
      size: j['size'] as int,
    );
  }
}

class NewsReportDto {
  final int id;
  final String? email;
  final int? userId;
  final String? userFullName;
  final String text;
  final NewsReportStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final int? articleId;
  final String? adminNote;
  final List<NewsReportFileDto> files;

  NewsReportDto({
    required this.id,
    required this.email,
    required this.userId,
    required this.userFullName,
    required this.text,
    required this.status,
    required this.createdAt,
    required this.processedAt,
    required this.articleId,
    required this.adminNote,
    required this.files,
  });

  factory NewsReportDto.fromJson(Map<String, dynamic> j) {
    return NewsReportDto(
      id: j['id'] as int,
      email: j['email'] as String?,
      userId: j['userId'] as int?,
      userFullName: j['userFullName'] as String?,
      text: j['text'] as String,
      status: newsReportStatusFromJson(j['status']),
      createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      processedAt: j['processedAt'] != null
          ? DateTime.parse(j['processedAt'] as String).toLocal()
          : null,
      articleId: j['articleId'] as int?,
      adminNote: j['adminNote'] as String?,
      files: (j['files'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(NewsReportFileDto.fromJson)
          .toList(),
    );
  }
}

class NewsReportSearch extends BaseSearch {
  final NewsReportStatus? status;

  const NewsReportSearch({
    this.status,
    super.fts,
    super.page = 0,
    super.pageSize = 10,
    super.includeTotalCount = true,
    super.retrieveAll = false,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();
    if (status != null) {
      q['status'] = newsReportStatusToJson(status!);
    }
    return q;
  }
}

class UpdateNewsReportStatusRequest {
  final NewsReportStatus status;
  final String? adminNote;
  final int? articleId;

  UpdateNewsReportStatusRequest({
    required this.status,
    this.adminNote,
    this.articleId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'status': newsReportStatusToJson(status)};

    if (adminNote != null && adminNote!.trim().isNotEmpty) {
      map['adminNote'] = adminNote!.trim();
    }
    if (articleId != null) {
      map['articleId'] = articleId;
    }

    return map;
  }
}
