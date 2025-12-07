namespace NovinskiPortal.Services.Database.Entities
{
    public class AdminReportExport
    {
        public int Id { get; set; }

        public int? AdminUserId { get; set; }
        public User? AdminUser { get; set; }

        public DateTime From { get; set; }
        public DateTime To { get; set; }

        public int TotalArticles { get; set; }
        public int TotalViews { get; set; }
        public int TotalComments { get; set; }
        public int NewUsers { get; set; }

        public string TopArticlesJson { get; set; } = default!;
        public string CategoryStatsJson { get; set; } = default!;
        public string ModerationStatsJson { get; set; } = default!;

        public DateTime CreatedAt { get; set; }
    }
}