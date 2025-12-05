using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.ArticleCommentReportService
{
    public interface IArticleCommentReportService
    {
        Task<(ArticleCommentResponse? Comment, string? ErrorCode)> ReportAsync(ArticleCommentReportRequest request, int currentUserId);
    }
}
