using NovinskiPortal.Common.Enumerations;

namespace NovinskiPortal.Services.Database.Entities
{
   public class NewsReport
    {
        public int Id { get; set; }

        public string? Email { get; set; }

        public int? UserId { get; set; }

        public string Text { get; set; } = default!;

        public NewsReportStatus Status { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime? ProcessedAt { get; set; }

        public int? ArticleId { get; set; }

        public string? AdminNote { get; set; }

        public virtual User? User { get; set; }

        public virtual Article? Article { get; set; }

        public virtual ICollection<NewsReportFile> Files { get; set; } = new List<NewsReportFile>();
    }
}
