namespace NovinskiPortal.Model.Responses
{
    public class AdminDashboardSummaryResponse
    {
        public int TotalArticles { get; set; }
        public int TotalUsers { get; set; } 
        public int ViewsLast7Days { get; set; } 
        public int NewArticlesLast7Days { get; set; }

        public List<TopArticleDashboardResponse> TopArticles { get; set; } = new();
        public List<DailyArticlesDashboardResponse> DailyArticlesLast30Days { get; set; } = new();
        public List<CategoryViewsDashboardResponse> CategoryViewsLast30Days { get; set; } = new();
    }
}
