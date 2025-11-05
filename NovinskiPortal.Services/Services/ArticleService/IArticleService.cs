using NovinskiPortal.Model.Requests.Article;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseCRUDService;

namespace NovinskiPortal.Services.Services.ArticleService
{
    public interface IArticleService : ICRUDService<ArticleResponse, ArticleSearchObject, CreateArticleRequest, UpdateArticleRequest >
    {
        Task<ArticleDetailResponse?> GetDetailByIdAsync(int id);
        Task<ArticleResponse?> ToggleArticleStatusAsync(int id);
    }
}
