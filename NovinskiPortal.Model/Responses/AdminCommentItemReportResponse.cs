using NovinskiPortal.Common.Enumerations;

namespace NovinskiPortal.Model.Responses
{
    public class AdminCommentItemReportResponse
    {
        public int Id { get; set; }

        public int ReporterUserId { get; set; }
        public string ReporterUsername { get; set; } = default!;

        public string Reason { get; set; } = default!;

        public DateTime CreatedAt { get; set; }

        public ArticleCommentReportStatus Status { get; set; }

        public DateTime? ProcessedAt { get; set; }

        public int? ProcessedByAdminId { get; set; }
        public string? ProcessedByAdminUsername { get; set; }

        public string? AdminNote { get; set; }
    }
}
