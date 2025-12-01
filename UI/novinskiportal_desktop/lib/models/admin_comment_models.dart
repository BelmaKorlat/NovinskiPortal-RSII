import '../core/base_search.dart';

enum ArticleCommentReportStatus { pending, approved, rejected }

String articleCommentReportStatusToJson(ArticleCommentReportStatus status) {
  switch (status) {
    case ArticleCommentReportStatus.pending:
      return 'Pending';
    case ArticleCommentReportStatus.approved:
      return 'Approved';
    case ArticleCommentReportStatus.rejected:
      return 'Rejected';
  }
}

ArticleCommentReportStatus? articleCommentReportStatusFromJson(dynamic value) {
  if (value == null) return null;

  if (value is String) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ArticleCommentReportStatus.pending;
      case 'approved':
        return ArticleCommentReportStatus.approved;
      case 'rejected':
        return ArticleCommentReportStatus.rejected;
    }
  }

  if (value is int) {
    if (value >= 0 && value < ArticleCommentReportStatus.values.length) {
      return ArticleCommentReportStatus.values[value];
    }
  }

  return null;
}

class AdminCommentReportResponse {
  final int id;
  final int articleId;
  final String articleHeadline;
  final int commentAuthorId;
  final String commentAuthorUsername;
  final String content;
  final int reportsCount;
  final int pendingReportsCount;
  final DateTime? firstReportedAt;
  final DateTime? lastReportedAt;
  final bool hasPendingReports;
  final bool isHidden;
  final bool isDeleted;

  AdminCommentReportResponse({
    required this.id,
    required this.articleId,
    required this.articleHeadline,
    required this.commentAuthorId,
    required this.commentAuthorUsername,
    required this.content,
    required this.reportsCount,
    required this.pendingReportsCount,
    required this.firstReportedAt,
    required this.lastReportedAt,
    required this.hasPendingReports,
    required this.isHidden,
    required this.isDeleted,
  });

  factory AdminCommentReportResponse.fromJson(Map<String, dynamic> j) {
    return AdminCommentReportResponse(
      id: j['id'] as int,
      articleId: j['articleId'] as int,
      articleHeadline: j['articleHeadline'] as String,
      commentAuthorId: j['commentAuthorId'] as int,
      commentAuthorUsername: j['commentAuthorUsername'] as String,
      content: j['content'] as String,
      reportsCount: j['reportsCount'] as int,
      pendingReportsCount: j['pendingReportsCount'] as int,
      firstReportedAt: j['firstReportedAt'] != null
          ? DateTime.parse(j['firstReportedAt'] as String).toLocal()
          : null,
      lastReportedAt: j['lastReportedAt'] != null
          ? DateTime.parse(j['lastReportedAt'] as String).toLocal()
          : null,
      hasPendingReports: j['hasPendingReports'] as bool,
      isHidden: j['isHidden'] as bool,
      isDeleted: j['isDeleted'] as bool,
    );
  }
}

class AdminCommentReportSearch extends BaseSearch {
  final ArticleCommentReportStatus? status;

  const AdminCommentReportSearch({
    this.status,
    super.page = 0,
    super.pageSize = 10,
    super.includeTotalCount = true,
    super.retrieveAll = false,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();

    if (status != null) {
      q['status'] = articleCommentReportStatusToJson(status!);
    }

    return q;
  }
}

DateTime? _parseUtcToLocal(dynamic value) {
  if (value == null) return null;
  if (value is! String || value.isEmpty) return null;

  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {
    return null;
  }
}

class AdminCommentItemReportResponse {
  final int id;
  final int reporterUserId;
  final String reporterUsername;
  final String reason;
  final ArticleCommentReportStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final int? processedByAdminId;
  final String? processedByAdminUsername;
  final String? adminNote;

  AdminCommentItemReportResponse({
    required this.id,
    required this.reporterUserId,
    required this.reporterUsername,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.processedAt,
    required this.processedByAdminId,
    required this.processedByAdminUsername,
    required this.adminNote,
  });

  factory AdminCommentItemReportResponse.fromJson(Map<String, dynamic> j) {
    return AdminCommentItemReportResponse(
      id: j['id'] as int,
      reporterUserId: j['reporterUserId'] as int,
      reporterUsername: j['reporterUsername'] as String,
      reason: j['reason'] as String,
      status:
          articleCommentReportStatusFromJson(j['status']) ??
          ArticleCommentReportStatus.pending,
      createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      processedAt: _parseUtcToLocal(j['processedAt']),
      processedByAdminId: j['processedByAdminId'] as int?,
      processedByAdminUsername: j['processedByAdminUsername'] as String?,
      adminNote: j['adminNote'] as String?,
    );
  }
}

class AdminCommentDetailReportResponse {
  final int id;
  final int articleId;
  final String articleHeadline;
  final int commentAuthorId;
  final String commentAuthorUsername;
  final String content;
  final DateTime commentCreatedAt;
  final int reportsCount;
  final int pendingReportsCount;
  final DateTime? firstReportedAt;
  final DateTime? lastReportedAt;
  final bool isHidden;
  final bool isDeleted;
  final DateTime? authorCommentBanUntil;
  final String? authorCommentBanReason;

  final List<AdminCommentItemReportResponse> reports;

  AdminCommentDetailReportResponse({
    required this.id,
    required this.articleId,
    required this.articleHeadline,
    required this.commentAuthorId,
    required this.commentAuthorUsername,
    required this.content,
    required this.commentCreatedAt,
    required this.reportsCount,
    required this.pendingReportsCount,
    required this.firstReportedAt,
    required this.lastReportedAt,
    required this.isHidden,
    required this.isDeleted,
    required this.authorCommentBanUntil,
    required this.authorCommentBanReason,
    required this.reports,
  });

  factory AdminCommentDetailReportResponse.fromJson(Map<String, dynamic> j) {
    return AdminCommentDetailReportResponse(
      id: j['id'] as int,
      articleId: j['articleId'] as int,
      articleHeadline: j['articleHeadline'] as String,
      commentAuthorId: j['commentAuthorId'] as int,
      commentAuthorUsername: j['commentAuthorUsername'] as String,
      content: j['content'] as String,
      commentCreatedAt: DateTime.parse(
        j['commentCreatedAt'] as String,
      ).toLocal(),
      reportsCount: j['reportsCount'] as int,
      pendingReportsCount: j['pendingReportsCount'] as int,
      firstReportedAt: _parseUtcToLocal(j['firstReportedAt']),
      lastReportedAt: _parseUtcToLocal(j['lastReportedAt']),
      isHidden: j['isHidden'] as bool,
      isDeleted: j['isDeleted'] as bool,
      authorCommentBanUntil: _parseUtcToLocal(j['authorCommentBanUntil']),
      authorCommentBanReason: j['authorCommentBanReason'] as String?,
      reports: (j['reports'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminCommentItemReportResponse.fromJson)
          .toList(),
    );
  }
}

class BanCommentAuthorRequest {
  final DateTime banUntil;
  final String? reason;

  BanCommentAuthorRequest({required this.banUntil, this.reason});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'banUntil': banUntil.toUtc().toIso8601String(),
    };

    final r = reason?.trim();
    if (r != null && r.isNotEmpty) {
      map['reason'] = r;
    }

    return map;
  }
}
