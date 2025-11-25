using NovinskiPortal.Common.Enumerations;

namespace NovinskiPortal.Model.Requests.NewsReport
{
    public class UpdateNewsReportStatusRequest
    {
        public NewsReportStatus Status { get; set; }

        public string? AdminNote { get; set; }

        public int? ArticleId { get; set; }
    }
}
