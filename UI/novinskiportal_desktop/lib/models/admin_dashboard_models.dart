class DashboardTopArticle {
  final int articleId;
  final String title;
  final int totalViews;
  final int categoryId;
  final String categoryName;

  DashboardTopArticle({
    required this.articleId,
    required this.title,
    required this.totalViews,
    required this.categoryId,
    required this.categoryName,
  });

  factory DashboardTopArticle.fromJson(Map<String, dynamic> json) {
    return DashboardTopArticle(
      articleId: json['articleId'] as int,
      title: json['title'] as String? ?? '',
      totalViews: json['totalViews'] as int? ?? 0,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
    );
  }
}

class DashboardDailyArticles {
  final DateTime date;
  final int totalArticles;

  DashboardDailyArticles({required this.date, required this.totalArticles});

  factory DashboardDailyArticles.fromJson(Map<String, dynamic> json) {
    return DashboardDailyArticles(
      date: DateTime.parse(json['date'] as String),
      totalArticles: json['totalArticles'] as int? ?? 0,
    );
  }
}

class DashboardCategoryViews {
  final int categoryId;
  final String categoryName;
  final int totalViews;

  DashboardCategoryViews({
    required this.categoryId,
    required this.categoryName,
    required this.totalViews,
  });

  factory DashboardCategoryViews.fromJson(Map<String, dynamic> json) {
    return DashboardCategoryViews(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      totalViews: json['totalViews'] as int? ?? 0,
    );
  }
}

class DashboardSummary {
  final int totalArticles;
  final int totalUsers;
  final int viewsLast7Days;
  final int newArticlesLast7Days;

  final List<DashboardTopArticle> topArticles;
  final List<DashboardDailyArticles> dailyArticlesLast30Days;
  final List<DashboardCategoryViews> categoryViewsLast30Days;

  DashboardSummary({
    required this.totalArticles,
    required this.totalUsers,
    required this.viewsLast7Days,
    required this.newArticlesLast7Days,
    required this.topArticles,
    required this.dailyArticlesLast30Days,
    required this.categoryViewsLast30Days,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final topArticlesJson = json['topArticles'] as List<dynamic>? ?? [];
    final dailyArticlesJson =
        json['dailyArticlesLast30Days'] as List<dynamic>? ?? [];
    final categoryViewsJson =
        json['categoryViewsLast30Days'] as List<dynamic>? ?? [];

    return DashboardSummary(
      totalArticles: json['totalArticles'] as int? ?? 0,
      totalUsers: json['totalUsers'] as int? ?? 0,
      viewsLast7Days: json['viewsLast7Days'] as int? ?? 0,
      newArticlesLast7Days: json['newArticlesLast7Days'] as int? ?? 0,
      topArticles: topArticlesJson
          .map((e) => DashboardTopArticle.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyArticlesLast30Days: dailyArticlesJson
          .map(
            (e) => DashboardDailyArticles.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      categoryViewsLast30Days: categoryViewsJson
          .map(
            (e) => DashboardCategoryViews.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
