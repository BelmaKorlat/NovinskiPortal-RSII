using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.ArticleCommentVoteService
{
    public interface IArticleCommentVoteService
    {
        Task<ArticleCommentResponse?> VoteAsync(ArticleCommentVoteRequest request, int currentUserId);
    }
}
