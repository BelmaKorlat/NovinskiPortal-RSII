using NovinskiPortal.Common.Enumerations;

namespace NovinskiPortal.Model.Responses
{
    public class NewsReportResponse
    {
        public int Id { get; set; }

        public string? Email { get; set; }

        public int? UserId { get; set; }

        public string? UserFullName { get; set; }

        public string Text { get; set; } = default!;

        public NewsReportStatus Status { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime? ProcessedAt { get; set; }

        public int? ArticleId { get; set; }

        public string? AdminNote { get; set; }

        public List<NewsReportFileResponse> Files { get; set; } = new();
    }
}
