using NovinskiPortal.Common.Enumerations;

namespace NovinskiPortal.Services.Database.Entities
{
    public class ArticleCommentReport
    {
        public int Id { get; set; }

        public int ArticleCommentId { get; set; }
        public ArticleComment ArticleComment { get; set; } = default!;

        public int ReporterUserId { get; set; }
        public User ReporterUser { get; set; } = default!;

        public string Reason { get; set; } = default!;

        public DateTime CreatedAt { get; set; }

        public ArticleCommentReportStatus Status { get; set; }

        public DateTime? ProcessedAt { get; set; }
        public int? ProcessedByAdminId { get; set; }
        public User? ProcessedByAdmin { get; set; } = default!;

        public string AdminNote { get; set; } = default!;
    }
}
