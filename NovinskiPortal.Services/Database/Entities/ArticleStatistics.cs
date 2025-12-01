using System;

namespace NovinskiPortal.Services.Database.Entities
{
    public class ArticleStatistics
    {
        public int Id { get; set; }
        public int ArticleId { get; set; }
        public Article Article { get; set; } = default!;
        public int TotalViews { get; set; }
        public DateTime? LastViewedAt { get; set; }
    }
}
