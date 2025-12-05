

using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.ArticleCommentService
{
    public interface IArticleCommentService : IService<ArticleCommentResponse, ArticleCommentReportSearchObject>
    {
        Task<(ArticleCommentResponse? Result, string? ErrorCode)> CreateAsync(int articleId, ArticleCommentCreateRequest request, int currentUserId);
        Task<PagedResult<ArticleCommentResponse>> GetArticleCommentAsync(ArticleCommentReportSearchObject search, int? currentUserId);
    }
}
