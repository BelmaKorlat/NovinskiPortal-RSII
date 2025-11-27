

using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.ArticleCommentService
{
    public interface IArticleCommentService : IService<ArticleCommentResponse, ArticleCommentSearchObject>
    {
        Task<ArticleCommentResponse?> CreateAsync(int articleId, ArticleCommentCreateRequest request, int currentUserId);
        Task<PagedResult<ArticleCommentResponse>> GetArticleCommentAsync(ArticleCommentSearchObject search, int? currentUserId);
    }
}
