namespace NovinskiPortal.Model.Responses
{
    public class AdminCommentReportResponse
    {
        public int Id { get; set; }

        public int ArticleId { get; set; }
        public string ArticleHeadline { get; set; } = default!;

        public int CommentAuthorId { get; set; }
        public string CommentAuthorUsername { get; set; } = default!;

        public string Content { get; set; } = default!;

        public int ReportsCount { get; set; }
        public int PendingReportsCount { get; set; }

        public DateTime? FirstReportedAt { get; set; }
        public DateTime? LastReportedAt { get; set; }

        public bool HasPendingReports { get; set; }

        public bool IsHidden { get; set; }
        public bool IsDeleted { get; set; }
    }
}
