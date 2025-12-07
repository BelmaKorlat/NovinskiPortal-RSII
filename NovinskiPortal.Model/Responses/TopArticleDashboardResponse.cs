namespace NovinskiPortal.Model.Responses
{
    public class TopArticleDashboardResponse
    {
        public int ArticleId { get; set; }
        public string Title { get; set; } = default!;
        public int TotalViews { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = default!;
    }
}
